-- Supabase Database Setup SQL (Cập Nhật Dựa Trên Phản Hồi Của Bạn)
-- Chạy trong SQL Editor. Sử dụng schema 'public' mặc định.
-- Nếu muốn schema 'plant_disease', uncomment các dòng dưới.
create schema IF not exists plant_disease;

set
search_path to plant_disease;

-- Tạo bảng crops (giữ nguyên: thêm description và image_url)
create table if not exists crops (
                                     id SERIAL primary key,
                                     name VARCHAR(255) not null,
    scientific_name VARCHAR(255) not null,
    description TEXT, -- Để hỗ trợ thư viện cây trồng
    image_url TEXT, -- URL ảnh từ Supabase Storage
    created_at timestamp with time zone default NOW(),
    updated_at timestamp with time zone default NOW()
    );

-- Tạo bảng diseases (loại bỏ severity theo yêu cầu của bạn)
create table if not exists diseases (
                                        id SERIAL primary key,
                                        crop_id INTEGER not null references crops (id) on delete CASCADE,
    class_name VARCHAR(255) not null,
    display_name VARCHAR(255) not null,
    description TEXT,
    treatment TEXT,
    image_url TEXT, -- URL ảnh bệnh
    created_at timestamp with time zone default NOW(),
    updated_at timestamp with time zone default NOW()
    );

-- Tạo bảng profiles (thay thế users, tích hợp với Supabase Auth, thêm location)
create table if not exists profiles (
                                        id UUID primary key references auth.users (id) on delete CASCADE,
    username VARCHAR(255) not null unique,
    role VARCHAR(50) not null default 'user',
    location VARCHAR(255), -- Để cá nhân hóa (có thể dùng cho thời tiết sau)
    created_at timestamp with time zone default NOW(),
    updated_at timestamp with time zone default NOW()
    );

-- Tạo bảng analysis_results (giữ nguyên từ script của bạn, thêm crop_id)
create table if not exists analysis_results (
                                                id SERIAL primary key,
                                                user_id UUID references auth.users (id) on delete set null, -- Liên kết với Auth
    crop_id INTEGER references crops (id) on delete set null, -- Để liên kết trực tiếp
    image_uri TEXT,
    plant_type VARCHAR(255),
    detected_diseases JSONB,
    confidence_score DECIMAL(3, 2),
    analysis_date timestamp with time zone default NOW(),
    location_data JSONB,
    notes TEXT
    );

-- Tạo indexes (cập nhật: bỏ index cho weather_data)
create index IF not exists idx_diseases_crop_id on diseases (crop_id);

create index IF not exists idx_diseases_class_name on diseases (class_name);

create index IF not exists idx_profiles_username on profiles (username);

create index IF not exists idx_analysis_results_user_id on analysis_results (user_id);

create index IF not exists idx_analysis_results_date on analysis_results (analysis_date);

-- Chèn dữ liệu mẫu cho crops và diseases (cập nhật: bỏ severity)
insert into
    crops (id, name, scientific_name, description, image_url)
values
    (
        1,
        'Apple Tree',
        'Malus domestica',
        'A popular fruit tree susceptible to various fungal diseases.',
        'https://images.pexels.com/photos/347926/pexels-photo-347926.jpeg?auto=compress&cs=tinysrgb&w=400'
    )
    on conflict (id) do update
                            set
                                name = EXCLUDED.name,
                            scientific_name = EXCLUDED.scientific_name,
                            description = EXCLUDED.description,
                            image_url = EXCLUDED.image_url;

insert into
    diseases (
    id,
    crop_id,
    class_name,
    display_name,
    description,
    treatment,
    image_url
)
values
    (
        101,
        1,
        'Apple___Apple_scab',
        'Apple Scab',
        'Caused by the fungus *Venturia inaequalis*. Symptoms include olive-green or brown spots on leaves and fruit, which later become black and scabby.',
        'Apply fungicides like captan, myclobutanil, or propiconazole. Remove fallen leaves and improve air circulation.',
        'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=300&fit=crop'
    ),
    (
        102,
        1,
        'Apple___Black_rot',
        'Apple Black Rot',
        'Caused by the fungus *Botryosphaeria obtusa*. On leaves, it creates "frogeye" spots with a tan center. On fruit, it causes a black, firm rot that spreads rapidly.',
        'Remove infected plant parts, apply copper-based fungicides, and ensure proper pruning for air circulation.',
        'https://images.unsplash.com/photo-1574263867128-a3d5c1b1deaa?w=400&h=300&fit=crop'
    ),
    (
        103,
        1,
        'Apple___Cedar_apple_rust',
        'Cedar Apple Rust',
        'Caused by the fungus *Gymnosporangium juniperi-virginianae*. On apple leaves, it creates small, yellow spots that enlarge and turn bright orange with black spots in the center.',
        'Remove nearby cedar trees if possible, apply preventive fungicides in spring, and choose resistant apple varieties.',
        'https://images.unsplash.com/photo-1574263867128-a3d5c1b1deaa?w=400&h=300&fit=crop'
    ),
    (
        104,
        1,
        'Apple___healthy',
        'Healthy',
        'The leaf shows no visible signs of common diseases. The surface is green, with no spots, distortions, or unusual discoloration.',
        'Continue regular care: proper watering, fertilization, and monitoring for early disease detection.',
        'https://images.unsplash.com/photo-1574263867128-a3d5c1b1deaa?w=400&h=300&fit=crop'
    )
    on conflict (id) do update
                            set
                                crop_id = EXCLUDED.crop_id,
                            class_name = EXCLUDED.class_name,
                            display_name = EXCLUDED.display_name,
                            description = EXCLUDED.description,
                            treatment = EXCLUDED.treatment,
                            image_url = EXCLUDED.image_url;

-- Bật Row Level Security (cập nhật: bỏ cho weather_data)
alter table crops ENABLE row LEVEL SECURITY;

alter table diseases ENABLE row LEVEL SECURITY;

alter table profiles ENABLE row LEVEL SECURITY;

alter table analysis_results ENABLE row LEVEL SECURITY;

-- Tạo policies (cập nhật: bỏ cho weather_data)
create policy "Allow read access to crops" on crops for
select
    using (true);

create policy "Allow read access to diseases" on diseases for
select
    using (true);

create policy "Users can read their own data" on profiles for
select
    using (auth.uid () = id);

create policy "Users can manage their own analysis results" on analysis_results for all using (auth.uid () = user_id);

-- Tạo hàm search_diseases và search_crops (giữ nguyên từ script của bạn)
create or replace function search_diseases (search_term TEXT) RETURNS table (
  id INTEGER,
  crop_id INTEGER,
  class_name VARCHAR(255),
  display_name VARCHAR(255),
  description TEXT,
  treatment TEXT,
  crop_name VARCHAR(255),
  crop_scientific_name VARCHAR(255)
) as $$
BEGIN
RETURN QUERY
SELECT
    d.id,
    d.crop_id,
    d.class_name,
    d.display_name,
    d.description,
    d.treatment,
    c.name as crop_name,
    c.scientific_name as crop_scientific_name
FROM diseases d
         JOIN crops c ON d.crop_id = c.id
WHERE
    d.display_name ILIKE '%' || search_term || '%' OR
        d.description ILIKE '%' || search_term || '%' OR
        c.name ILIKE '%' || search_term || '%'
ORDER BY d.display_name;
END;
$$ LANGUAGE plpgsql;

create or replace function search_crops (search_term TEXT) RETURNS table (
  id INTEGER,
  name VARCHAR(255),
  scientific_name VARCHAR(255),
  description JSONB,
  image_url TEXT,
  disease_count BIGINT
) as $$
BEGIN
RETURN QUERY
SELECT
    c.id,
    c.name,
    c.scientific_name,
    c.description,
    c.image_url,
    COUNT(d.id) as disease_count
FROM crops c
         LEFT JOIN diseases d ON c.id = d.crop_id
WHERE
    c.name ILIKE '%' || search_term || '%' OR
        c.scientific_name ILIKE '%' || search_term || '%' OR
        (c.description->>'legacy_description') ILIKE '%' || search_term || '%' OR
        (c.description->>'overview'->>'description') ILIKE '%' || search_term || '%'
GROUP BY c.id, c.name, c.scientific_name, c.description, c.image_url
ORDER BY c.name;
END;
$$ LANGUAGE plpgsql;

create or replace function get_disease_stats () RETURNS table (
  total_crops INTEGER,
  total_diseases INTEGER,
  diseases_per_crop JSONB
) as $$
BEGIN
RETURN QUERY
SELECT
    (SELECT COUNT(*)::INTEGER FROM crops) as total_crops,
    (SELECT COUNT(*)::INTEGER FROM diseases) as total_diseases,
    (SELECT jsonb_object_agg(c.name, disease_count)
     FROM (
              SELECT c.name, COUNT(d.id) as disease_count
              FROM crops c
                       LEFT JOIN diseases d ON c.id = d.crop_id
              GROUP BY c.id, c.name
          ) c) as diseases_per_crop;
END;
$$ LANGUAGE plpgsql;

-- Tạo trigger cho updated_at (áp dụng cho các bảng)
create or replace function update_timestamp () RETURNS TRIGGER as $$
BEGIN
   NEW.updated_at = NOW();
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

create trigger update_crops_timestamp BEFORE
    update on crops for EACH row
    execute PROCEDURE update_timestamp ();

create trigger update_diseases_timestamp BEFORE
    update on diseases for EACH row
    execute PROCEDURE update_timestamp ();

create trigger update_profiles_timestamp BEFORE
    update on profiles for EACH row
    execute PROCEDURE update_timestamp ();

create trigger update_analysis_results_timestamp BEFORE
    update on analysis_results for EACH row
    execute PROCEDURE update_timestamp ();

insert into
    plant_disease.profiles (id, username, role, location)
values
    (
        '123e4567-e89b-12d3-a456-426614174000',
        'admin_user',
        'admin',
        'Hanoi'
    ),
    (
        'another-uuid-from-auth',
        'farmer_a',
        'user',
        'New York'
    )
    on conflict (id) do update
                            set
                                username = EXCLUDED.username,
                            role = EXCLUDED.role,
                            location = EXCLUDED.location;

insert into
    plant_disease.analysis_results (
    user_id,
    crop_id,
    image_uri,
    plant_type,
    detected_diseases,
    confidence_score,
    location_data,
    notes
)
values
    (
        '41872386-c70b-419d-b27e-6022033dff99',
        1,
        'https://www.shutterstock.com/image-photo/apple-scab-caused-by-venturia-inaequalis-2646179817',
        'Apple Tree',
        '{"disease": "Apple Scab", "details": "High risk"}'::JSONB,
        0.95,
        '{"lat": 21.0, "lon": 105.8}'::JSONB,
        'Test scan from camera'
    )
    on conflict do nothing;



    -- Chuyển đổi cột description sang JSONB
ALTER TABLE plant_disease.crops 
ALTER COLUMN description TYPE jsonb 
USING CASE 
    WHEN description IS NULL OR description = '' THEN '{}'::jsonb
    ELSE ('{"legacy_description": "' || replace(description, '"', '\"') || '"}')::jsonb
END;

-- Cập nhật thông tin chi tiết cho cây táo
UPDATE plant_disease.crops 
SET description = '{
  "overview": {
    "description": "Apple trees are deciduous fruit trees belonging to the rose family, widely cultivated for their sweet and nutritious fruits. They are one of the most popular and economically important fruit crops worldwide, with thousands of varieties adapted to different climates and growing conditions.",
    "basic_info": {
      "scientific_name": "Malus domestica",
      "family": "Rosaceae (Rose family)",
      "common_names": ["Apple tree", "Domestic apple", "Orchard apple"],
      "origin": "Central Asia, specifically Kazakhstan and surrounding regions",
      "tree_type": "Deciduous fruit tree",
      "mature_height": "6-40 feet (depending on rootstock and variety)",
      "mature_width": "6-30 feet",
      "life_span": "50-100+ years with proper care"
    },
    "growing_conditions": {
      "climate": "Temperate climate with cold winters for proper dormancy",
      "temperature": "Optimal growing temperature: 60-75°F (15-24°C)",
      "chill_hours": "Requires 500-1000+ chill hours below 45°F (7°C) depending on variety",
      "hardiness_zones": "USDA zones 3-9 (varies by variety)",
      "sunlight": "Full sun (6-8 hours daily minimum)",
      "soil_type": "Well-draining, fertile loam with pH 6.0-7.0",
      "soil_depth": "Deep soil preferred, minimum 3 feet",
      "water_requirements": "1-2 inches per week, consistent moisture",
      "spacing": "Standard trees: 25-35 feet apart, Dwarf trees: 6-10 feet apart"
    },
    "growing_season": {
      "planting_time": "Late winter to early spring (dormant season) or fall in mild climates",
      "blooming_period": "Early to mid-spring (April-May in Northern Hemisphere)",
      "fruit_development": "Spring through summer (3-5 months after bloom)",
      "harvest_time": "Late summer to fall (August-October depending on variety)",
      "dormancy_period": "Late fall through winter",
      "first_harvest": "2-6 years after planting (depending on rootstock and variety)"
    }
  },
  "growing_tips": {
    "site_selection": {
      "location": "Choose a sunny, well-ventilated site protected from strong winds",
      "soil_preparation": "Test soil pH and improve drainage. Add organic matter like compost",
      "avoid": "Low-lying areas prone to frost, poorly drained soils, areas with standing water"
    },
    "planting": {
      "timing": "Plant during dormancy period for best establishment",
      "hole_preparation": "Dig hole twice as wide as root ball, same depth as container",
      "rootstock_consideration": "Choose appropriate rootstock for your space and climate",
      "pollination": "Most apples need cross-pollination - plant 2+ compatible varieties"
    },
    "watering": {
      "establishment": "Water deeply 2-3 times per week for first year",
      "mature_trees": "Deep weekly watering during growing season",
      "drought_stress": "Maintain consistent moisture during fruit development",
      "winter": "Reduce watering frequency but do not let trees completely dry out"
    },
    "fertilizing": {
      "young_trees": "Apply balanced 10-10-10 fertilizer in early spring",
      "mature_trees": "Annual application of compost or aged manure in spring",
      "timing": "Fertilize in early spring before bud break",
      "avoid": "Excessive nitrogen which promotes excessive vegetative growth"
    },
    "pruning": {
      "timing": "Late winter during dormancy (February-March)",
      "goals": "Remove dead/diseased wood, improve air circulation, maintain shape",
      "young_trees": "Focus on establishing strong scaffold branches",
      "mature_trees": "Annual pruning to maintain size and productivity"
    },
    "pest_management": {
      "integrated_approach": "Combine cultural, biological, and chemical controls as needed",
      "common_pests": "Aphids, codling moth, apple maggot, scale insects",
      "beneficial_insects": "Encourage ladybugs, lacewings, and parasitic wasps",
      "monitoring": "Regular inspection for early pest detection"
    },
    "disease_prevention": {
      "air_circulation": "Proper pruning and spacing to reduce humidity",
      "sanitation": "Remove fallen leaves and fruit to reduce disease pressure",
      "resistant_varieties": "Choose disease-resistant cultivars when possible",
      "preventive_sprays": "Apply dormant oil and copper fungicide as preventive measures"
    },
    "harvesting": {
      "ripeness_indicators": "Easy separation from branch, brown seeds, proper color development",
      "timing": "Harvest at optimal ripeness for best flavor and storage",
      "handling": "Handle gently to avoid bruising",
      "storage": "Store in cool, humid conditions for extended shelf life"
    },
    "seasonal_care": {
      "spring": "Pruning, fertilizing, pest monitoring, bloom protection from frost",
      "summer": "Regular watering, fruit thinning, pest/disease management",
      "fall": "Harvesting, cleanup of fallen fruit and leaves, winter preparation",
      "winter": "Protection from rodents, planning for next season, equipment maintenance"
    }
  }
}'::jsonb,
name = 'Apple Tree',
scientific_name = 'Malus domestica',
updated_at = NOW()
WHERE id = 1;

-- Function để lấy thông tin overview
CREATE OR REPLACE FUNCTION get_crop_overview(crop_id INTEGER)
RETURNS TABLE (
    name VARCHAR(255),
    overview JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.name,
        c.description->'overview' as overview
    FROM crops c
    WHERE c.id = crop_id;
END;
$$ LANGUAGE plpgsql;

-- Function để lấy growing tips
CREATE OR REPLACE FUNCTION get_crop_growing_tips(crop_id INTEGER)
RETURNS TABLE (
    name VARCHAR(255),
    growing_tips JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.name,
        c.description->'growing_tips' as growing_tips
    FROM crops c
    WHERE c.id = crop_id;
END;
$$ LANGUAGE plpgsql;
