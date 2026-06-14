# SPEC WEBSITE DEMO PHÁT HIỆN SÂU BỆNH TRÊN LÁ CÂY

## 1. Mục tiêu dự án

Xây dựng một website demo trực tiếp cho ứng dụng Flutter phát hiện sâu bệnh trên lá cây, phục vụ mục tiêu giới thiệu năng lực với nhà tuyển dụng. Người xem có thể truy cập website qua URL, tải ảnh lá cây lên, nhận kết quả dự đoán, xem độ tin cậy của model, đọc thông tin về cây trồng/bệnh cây và hiểu được công nghệ đã sử dụng mà không cần clone GitHub hoặc chạy project local.

Website cần thể hiện rõ ba năng lực chính:

1. Năng lực phát triển ứng dụng Flutter đa nền tảng.
2. Năng lực tích hợp AI/computer vision vào sản phẩm thực tế.
3. Năng lực đóng gói, triển khai và trình bày project theo chuẩn portfolio chuyên nghiệp.

---

## 2. Phạm vi sản phẩm

### 2.1. Tính năng bắt buộc

Website phải có các tính năng sau:

1. Trang giới thiệu dự án.
2. Trang demo upload ảnh lá cây.
3. Chức năng kiểm tra ảnh hợp lệ.
4. Chức năng nhận diện bệnh/sâu bệnh từ ảnh.
5. Hiển thị kết quả dự đoán.
6. Hiển thị độ tin cậy của kết quả.
7. Hiển thị top-k kết quả có khả năng cao nhất.
8. Hiển thị thông tin chi tiết về bệnh/cây trồng liên quan.
9. Trang danh sách cây trồng/bệnh cây.
10. Trang chi tiết từng loại cây trồng/bệnh cây.
11. Trang giải thích công nghệ, model, dataset và giới hạn của hệ thống.
12. Link GitHub, CV/portfolio và thông tin liên hệ.
13. Deploy public trên Vercel.

### 2.2. Tính năng nên có

1. Kéo-thả ảnh vào vùng upload.
2. Ảnh mẫu để nhà tuyển dụng test nhanh.
3. Loading state khi model đang tải hoặc đang dự đoán.
4. Error state rõ ràng khi ảnh không hợp lệ.
5. Responsive tốt trên desktop, tablet và mobile.
6. So sánh ảnh đầu vào với kết quả.
7. Nút “Try another image”.
8. Nút “View disease details”.
9. Disclaimer rằng kết quả chỉ mang tính tham khảo, không thay thế chuyên gia nông nghiệp.
10. Analytics cơ bản để biết có bao nhiêu lượt truy cập/demo.
11. Trang “Model Card” mô tả model AI.

### 2.3. Tính năng chưa nên làm ở bản đầu

1. Đăng nhập/đăng ký người dùng.
2. Lưu lịch sử dự đoán dài hạn.
3. Dashboard admin phức tạp.
4. Chatbot AI.
5. Gợi ý thuốc bảo vệ thực vật cụ thể theo liều lượng.
6. Upload hàng loạt nhiều ảnh.
7. Tính năng thương mại hóa.

Lý do: mục tiêu hiện tại là demo tuyển dụng. Cần ưu tiên website chạy ổn định, dễ hiểu, dễ test, không làm quá rộng khiến dự án bị dang dở.

---

## 3. Đối tượng người dùng

### 3.1. Nhà tuyển dụng / người phỏng vấn kỹ thuật

Nhu cầu:

* Mở website nhanh.
* Test thử tính năng upload ảnh.
* Xem kết quả AI có hợp lý không.
* Hiểu project dùng công nghệ gì.
* Xem GitHub/source code.
* Đánh giá khả năng triển khai sản phẩm thực tế.

### 3.2. Người dùng phổ thông

Nhu cầu:

* Tải ảnh lá cây lên.
* Biết lá cây có thể bị bệnh gì.
* Đọc thông tin cơ bản về bệnh/cây trồng.
* Hiểu cách xử lý ở mức tham khảo.

### 3.3. Chủ dự án

Nhu cầu:

* Có một demo đẹp, ổn định để đưa vào CV.
* Có link deploy public.
* Có project thể hiện được cả mobile, web, AI và deployment.
* Có tài liệu rõ ràng để giải thích khi phỏng vấn.

---

## 4. User Flow chính

### Flow 1: Nhà tuyển dụng test nhanh

1. Mở link website.
2. Đọc phần giới thiệu ngắn.
3. Bấm “Try Demo”.
4. Chọn một ảnh mẫu hoặc upload ảnh lá cây.
5. Website preview ảnh.
6. Người dùng bấm “Detect Disease”.
7. Hệ thống xử lý ảnh.
8. Hiển thị kết quả:

   * Tên cây/bệnh.
   * Độ tin cậy.
   * Top-k predictions.
   * Mô tả ngắn.
   * Hướng dẫn xem chi tiết.
9. Người dùng mở trang chi tiết bệnh.
10. Người dùng xem GitHub/tech stack.

### Flow 2: Người dùng upload ảnh không hợp lệ

1. Người dùng upload ảnh không phải lá cây hoặc file không hợp lệ.
2. Website kiểm tra định dạng/kích thước.
3. Website hiển thị lỗi thân thiện:

   * “Vui lòng tải ảnh JPG/PNG/WebP.”
   * “Dung lượng ảnh tối đa là X MB.”
   * “Ảnh nên chụp rõ một hoặc nhiều lá cây.”
4. Người dùng có thể chọn lại ảnh.

### Flow 3: Người dùng xem thông tin cây trồng

1. Mở trang “Plant Library” hoặc “Disease Library”.
2. Tìm kiếm theo tên cây/bệnh.
3. Lọc theo loại cây.
4. Mở trang chi tiết.
5. Xem mô tả, triệu chứng, nguyên nhân, cách phòng ngừa và hình ảnh minh họa.

---

## 5. Yêu cầu chức năng chi tiết

## FR1. Trang Landing Page

### Mô tả

Trang đầu tiên khi người dùng mở website. Mục tiêu là giải thích dự án trong 10–15 giây.

### Nội dung cần có

* Tên dự án.
* Một câu mô tả ngắn.
* Ảnh minh họa hoặc screenshot app.
* Nút “Try Demo”.
* Nút “View GitHub”.
* Nút “View Tech Stack”.
* Thông tin ngắn:

  * Flutter app.
  * AI disease detection.
  * Web demo deployed on Vercel.
  * Image classification/computer vision.

### Acceptance Criteria

* Người dùng hiểu website làm gì trong vòng 10 giây.
* Có nút dẫn tới demo rõ ràng.
* Có link GitHub hoạt động.
* Giao diện không bị vỡ trên mobile.
* Landing page tải nhanh và không bắt người dùng đăng nhập.

---

## FR2. Trang Demo Upload Ảnh

### Mô tả

Cho phép người dùng tải ảnh lá cây lên hoặc chọn ảnh mẫu để test.

### Thành phần UI

* Upload box.
* Drag & drop area.
* Button chọn file.
* Danh sách ảnh mẫu.
* Preview ảnh.
* Button “Detect Disease”.
* Button “Remove image”.
* Thông tin yêu cầu ảnh:

  * Định dạng: JPG, PNG, WebP.
  * Dung lượng tối đa: đề xuất 3–5 MB.
  * Ảnh nên rõ nét, đủ sáng, có lá cây.

### Validation

* Không nhận file không phải ảnh.
* Không nhận file quá dung lượng cho phép.
* Không nhận file rỗng.
* Hiển thị thông báo lỗi rõ ràng.
* Không crash nếu người dùng bấm detect khi chưa chọn ảnh.

### Acceptance Criteria

* Upload ảnh thành công trên Chrome, Edge, Firefox.
* Preview đúng ảnh đã chọn.
* Ảnh mẫu có thể dùng để test ngay.
* Khi upload file sai định dạng, website báo lỗi rõ.
* Khi ảnh quá lớn, website báo lỗi và hướng dẫn nén/chọn ảnh khác.
* Không reload toàn trang khi upload ảnh.

---

## FR3. Xử lý ảnh trước khi dự đoán

### Mô tả

Ảnh đầu vào phải được xử lý giống pipeline đã dùng khi train model/mobile app.

### Các bước cần có

* Resize ảnh về input size của model.
* Normalize pixel đúng theo model.
* Convert ảnh sang tensor/input format phù hợp.
* Đảm bảo thứ tự channel đúng: RGB/BGR nếu có.
* Đảm bảo scale đúng: 0–1, -1–1 hoặc mean/std tùy model.
* Xử lý ảnh bị xoay do EXIF nếu cần.

### Acceptance Criteria

* Cùng một ảnh test cho kết quả gần tương đương giữa mobile app và web.
* Pipeline preprocess được document trong README.
* Có bộ ảnh test cố định để so sánh output.
* Không làm méo ảnh quá mức gây sai lệch dự đoán.

---

## FR4. Chức năng nhận diện sâu bệnh

### Mô tả

Hệ thống nhận ảnh lá cây và trả về kết quả dự đoán.

### Phương án kỹ thuật ưu tiên

#### Phương án A: Inference trực tiếp trên trình duyệt

Dùng khi model đủ nhẹ và có thể chuyển sang định dạng chạy web.

Ưu điểm:

* Không cần backend riêng.
* Không tốn chi phí inference server.
* Ảnh không cần gửi lên server.
* Demo ổn định hơn nếu không có nhiều người dùng.
* Phù hợp portfolio cá nhân.

Nhược điểm:

* Model có thể bị tải về máy người dùng.
* Model lớn sẽ làm website tải chậm.
* Một số model/plugin mobile có thể không chạy trực tiếp trên web.

#### Phương án B: Frontend trên Vercel, inference API ở backend riêng

Dùng khi model lớn, khó convert sang web hoặc cần giữ model private.

Backend có thể là:

* FastAPI Python.
* Flask.
* Node.js inference server.
* Hugging Face Space.
* Railway.
* Render.
* Fly.io.
* Google Cloud Run.

Ưu điểm:

* Dễ dùng lại model Python/TensorFlow/PyTorch hiện tại.
* Model không bị tải xuống browser.
* Dễ kiểm soát inference.

Nhược điểm:

* Có thêm backend cần deploy.
* Có thể bị cold start.
* Cần xử lý upload ảnh, CORS, timeout, chi phí.
* Nếu gửi ảnh trực tiếp qua Vercel Function có thể gặp giới hạn payload.

### Output bắt buộc

* Predicted label.
* Tên bệnh/cây bằng tiếng Anh và/hoặc tiếng Việt.
* Confidence score.
* Top 3 predictions.
* Thời gian xử lý.
* Cảnh báo nếu confidence thấp.
* Link đến trang thông tin chi tiết.

### Acceptance Criteria

* Dự đoán trả kết quả trong thời gian chấp nhận được.
* Không crash khi ảnh khó nhận diện.
* Confidence hiển thị dễ hiểu.
* Nếu confidence thấp hơn threshold, hệ thống không khẳng định quá chắc.
* Kết quả top-k được hiển thị rõ.
* Có ít nhất 10 ảnh test dùng để kiểm tra trước khi deploy.

---

## FR5. Hiển thị kết quả dự đoán

### Mô tả

Sau khi inference, website hiển thị kết quả theo cách dễ hiểu và chuyên nghiệp.

### Nội dung kết quả

* Ảnh đã upload.
* Tên bệnh/cây dự đoán.
* Confidence.
* Top-k classes.
* Mô tả ngắn.
* Triệu chứng thường gặp.
* Gợi ý hành động ở mức tham khảo.
* Nút xem chi tiết.
* Nút thử ảnh khác.

### Confidence UX

Quy ước đề xuất:

* > = 80%: “High confidence”.
* 50%–79%: “Medium confidence”.
* < 50%: “Low confidence — please use a clearer image.”

### Acceptance Criteria

* Người dùng hiểu kết quả mà không cần kiến thức AI.
* Không dùng từ ngữ khẳng định tuyệt đối như “chắc chắn bị bệnh”.
* Có cảnh báo khi model không tự tin.
* Có đường dẫn sang thông tin chi tiết.
* Kết quả không bị mất khi người dùng resize màn hình.

---

## FR6. Thư viện cây trồng và bệnh cây

### Mô tả

Giữ lại tính năng hiện có trên app: xem thông tin về cây trồng và các loại bệnh/sâu bệnh.

### Dữ liệu cần có

Mỗi loại cây:

* ID.
* Tên tiếng Việt.
* Tên tiếng Anh.
* Tên khoa học nếu có.
* Mô tả.
* Điều kiện sinh trưởng.
* Các bệnh thường gặp.
* Hình ảnh minh họa.
* Nguồn tham khảo.

Mỗi loại bệnh:

* ID.
* Tên tiếng Việt.
* Tên tiếng Anh.
* Cây bị ảnh hưởng.
* Triệu chứng.
* Nguyên nhân.
* Điều kiện phát triển bệnh.
* Cách phòng ngừa.
* Cách xử lý ở mức tham khảo.
* Hình ảnh minh họa.
* Label tương ứng trong model.
* Nguồn tham khảo.

### Chức năng

* Xem danh sách cây.
* Xem danh sách bệnh.
* Tìm kiếm theo tên.
* Lọc theo cây trồng.
* Mở trang chi tiết.
* Điều hướng từ kết quả dự đoán sang bệnh tương ứng.

### Acceptance Criteria

* Dữ liệu hiển thị đúng với label model.
* Không có label dự đoán nhưng không có trang thông tin tương ứng.
* Có search/filter hoạt động.
* Trang chi tiết không bị trống nội dung.
* Nội dung có nguồn tham khảo hoặc ghi rõ là nội dung tổng hợp.

---

## FR7. Trang Model Card

### Mô tả

Trang giải thích model AI để nhà tuyển dụng thấy dự án không chỉ là giao diện.

### Nội dung cần có

* Mục tiêu model.
* Loại bài toán: image classification.
* Danh sách classes.
* Dataset đã sử dụng.
* Số lượng ảnh train/validation/test nếu có.
* Kích thước ảnh input.
* Kiến trúc model.
* Framework train model.
* Accuracy/precision/recall/F1 nếu có.
* Confusion matrix nếu có.
* Các giới hạn của model.
* Các trường hợp dễ dự đoán sai.
* Pipeline preprocess.
* Pipeline inference trên web.

### Acceptance Criteria

* Người phỏng vấn có thể hiểu model hoạt động ở mức tổng quan.
* Có số liệu đánh giá model.
* Có mô tả limitation trung thực.
* Có mapping giữa label model và nội dung hiển thị.
* Không phóng đại độ chính xác nếu chưa có dữ liệu kiểm chứng.

---

## FR8. Trang Tech Stack / Architecture

### Mô tả

Giải thích kiến trúc website và công nghệ sử dụng.

### Nội dung cần có

* Flutter Web.
* Vercel deployment.
* AI model format.
* Inference method.
* Data source cho plant/disease library.
* Architecture diagram.
* Repo structure.
* CI/CD flow.
* Các quyết định kỹ thuật quan trọng.

### Kiến trúc khuyến nghị cho bản MVP

```text
User Browser
   |
   |-- Flutter Web UI
   |-- Upload/Preview Image
   |-- Client-side Preprocessing
   |-- Client-side Inference
   |-- Local/Static Plant Disease Data
   |
Vercel Static Hosting
   |
   |-- build/web
   |-- assets/model
   |-- assets/data
   |-- assets/images
```

### Kiến trúc thay thế nếu model không chạy tốt trên browser

```text
User Browser
   |
   |-- Flutter Web UI on Vercel
   |
   |-- Upload image to AI API
           |
           |-- FastAPI / Cloud Run / Railway / Render
           |-- Load model
           |-- Run inference
           |-- Return prediction JSON
```

### Acceptance Criteria

* Có sơ đồ kiến trúc dễ hiểu.
* Người xem biết vì sao chọn client-side hoặc server-side inference.
* Có giải thích trade-off.
* Có thông tin deploy rõ ràng.
* Có link GitHub và README.

---

## FR9. Error Handling

### Các lỗi cần xử lý

* Không chọn ảnh.
* File không phải ảnh.
* File quá lớn.
* Ảnh bị lỗi/không đọc được.
* Model chưa tải xong.
* Model inference lỗi.
* Kết nối mạng lỗi nếu dùng backend.
* Backend timeout nếu dùng server-side inference.
* Không tìm thấy thông tin bệnh tương ứng.
* Browser không hỗ trợ một số tính năng cần thiết.

### Acceptance Criteria

* Không có lỗi làm trắng màn hình.
* Mọi lỗi chính đều có message dễ hiểu.
* Người dùng luôn có cách thử lại.
* Lỗi kỹ thuật không hiển thị stack trace ra UI production.

---

## FR10. Privacy & Security

### Nguyên tắc

* Bản demo không nên lưu ảnh người dùng mặc định.
* Nếu cần lưu ảnh để debug/analytics, phải thông báo rõ.
* Không thu thập thông tin cá nhân không cần thiết.
* Không yêu cầu đăng nhập ở MVP.
* Không public API key/token trong source frontend.
* Không để model hoặc data nhạy cảm nếu không muốn người dùng tải về.

### Với client-side inference

* Ảnh xử lý trong trình duyệt.
* Không gửi ảnh lên server.
* Cần ghi rõ điều này trên UI nếu muốn tạo điểm cộng về privacy.

### Với server-side inference

* Giới hạn kích thước ảnh.
* Validate MIME type.
* Rate limit API.
* Không lưu ảnh lâu dài nếu không cần.
* Xóa ảnh tạm sau inference.
* Cấu hình CORS đúng domain website.
* Không cho upload file nguy hiểm.

### Acceptance Criteria

* Không có secret trong repo public.
* Không upload ảnh lên server nếu không cần.
* Có disclaimer privacy ngắn ở trang demo.
* API có validation nếu dùng backend.
* Không cho file lớn hoặc file lạ đi vào inference pipeline.

---

## FR11. Performance

### Mục tiêu hiệu năng

* Landing page tải nhanh.
* Trang demo không bị đứng khi model đang load.
* Có loading state rõ ràng.
* Model được lazy-load khi người dùng vào trang demo.
* Asset ảnh được nén.
* Không tải toàn bộ dữ liệu không cần thiết ngay ở landing page.

### Tiêu chí đề xuất

* Landing page usable trong dưới 3 giây trên mạng bình thường.
* Model load có progress/loading indicator.
* Inference sau khi model đã load nên dưới 2–5 giây trên laptop phổ thông.
* Tổng bundle không quá lớn so với nhu cầu demo.
* Ảnh mẫu được tối ưu dung lượng.

### Acceptance Criteria

* Không có cảm giác website bị treo khi mở.
* Người dùng biết hệ thống đang làm gì trong lúc xử lý.
* Không tải model ngay ở landing page nếu chưa cần.
* Lighthouse Performance nên đạt mức chấp nhận được cho portfolio.

---

## FR12. Responsive UI

### Breakpoints cần kiểm tra

* Mobile: 360px–480px.
* Tablet: 768px.
* Laptop: 1366px.
* Desktop lớn: 1920px.

### Acceptance Criteria

* Upload box không bị tràn màn hình.
* Kết quả dự đoán đọc được trên mobile.
* Card thông tin cây/bệnh không bị vỡ layout.
* Header/menu hoạt động tốt trên mobile.
* Nút bấm đủ lớn để thao tác.

---

## FR13. Accessibility

### Yêu cầu

* Button có text rõ ràng.
* Ảnh có alt text nếu phù hợp.
* Contrast đủ đọc.
* Có trạng thái focus cho keyboard navigation.
* Không chỉ dùng màu để truyền đạt confidence.
* Error message có text rõ ràng.

### Acceptance Criteria

* Có thể dùng keyboard để thao tác cơ bản.
* Người dùng không bị phụ thuộc hoàn toàn vào màu sắc để hiểu kết quả.
* Text dễ đọc, không quá nhỏ.
* Form upload có label rõ ràng.

---

## FR14. SEO & Portfolio Presentation

### Yêu cầu

* Title rõ ràng.
* Description mô tả project.
* Open Graph image nếu chia sẻ link.
* Favicon.
* Project name nhất quán.
* Có phần “About this project”.
* Có phần “What I learned”.
* Có phần “Technical challenges”.
* Có phần “Future improvements”.

### Acceptance Criteria

* Link website khi gửi cho nhà tuyển dụng hiển thị tên/mô tả đẹp.
* Có thể hiểu đây là project cá nhân nghiêm túc.
* Có link GitHub, LinkedIn/portfolio/email.
* Có screenshot hoặc demo video ngắn.

---

## FR15. README & Documentation

### README cần có

* Project overview.
* Live demo link.
* Screenshots.
* Features.
* Tech stack.
* Architecture.
* Model information.
* How to run locally.
* How to build web.
* How to deploy.
* Known limitations.
* Future improvements.
* Credits/dataset sources.

### Acceptance Criteria

* Người xem GitHub hiểu project trong 1–2 phút.
* Có hướng dẫn chạy local rõ ràng.
* Có link live demo.
* Có ảnh minh họa.
* Có mô tả model và dữ liệu.
* Không thiếu file env example nếu có backend.

---

# 6. Yêu cầu phi chức năng

## 6.1. Stability

Website không được crash trong các thao tác phổ biến:

* Mở trang.
* Upload ảnh.
* Xóa ảnh.
* Upload lại ảnh.
* Chọn ảnh mẫu.
* Chạy detect nhiều lần.
* Resize màn hình.
* Chuyển qua lại giữa các trang.

## 6.2. Maintainability

Code cần tách rõ:

* UI components.
* Inference service.
* Image preprocessing.
* Data repository.
* Routing.
* Error handling.
* Config/constants.

## 6.3. Scalability

Bản MVP không cần scale lớn, nhưng cần tránh thiết kế gây khó mở rộng:

* Label mapping phải tách thành file riêng.
* Disease/crop data phải tách khỏi UI.
* Inference service phải có interface riêng để sau này đổi từ client-side sang API backend.
* Config threshold/confidence không hard-code rải rác.

## 6.4. Observability

Nên có:

* Basic analytics.
* Error logging.
* Console log chỉ dùng ở dev.
* Không log ảnh người dùng ở production nếu không có lý do.

---

# 7. Data Specification

## 7.1. Model Label Mapping

File đề xuất: `assets/data/label_mapping.json`

Ví dụ:

```json
[
  {
    "id": "tomato_late_blight",
    "modelLabel": "Tomato___Late_blight",
    "displayNameVi": "Bệnh mốc sương trên cà chua",
    "displayNameEn": "Tomato Late Blight",
    "cropId": "tomato",
    "diseaseId": "late_blight"
  }
]
```

## 7.2. Crop Data

File đề xuất: `assets/data/crops.json`

```json
[
  {
    "id": "tomato",
    "nameVi": "Cà chua",
    "nameEn": "Tomato",
    "scientificName": "Solanum lycopersicum",
    "description": "...",
    "commonDiseases": ["late_blight", "early_blight"],
    "image": "assets/images/crops/tomato.webp"
  }
]
```

## 7.3. Disease Data

File đề xuất: `assets/data/diseases.json`

```json
[
  {
    "id": "late_blight",
    "nameVi": "Bệnh mốc sương",
    "nameEn": "Late Blight",
    "affectedCrops": ["tomato", "potato"],
    "symptoms": ["..."],
    "causes": ["..."],
    "prevention": ["..."],
    "treatmentNote": "...",
    "references": ["..."],
    "images": ["assets/images/diseases/late_blight.webp"]
  }
]
```

## 7.4. Sample Images

Cần có thư mục ảnh mẫu:

```text
assets/sample_images/
  tomato_late_blight_01.webp
  tomato_healthy_01.webp
  potato_early_blight_01.webp
```

Acceptance Criteria:

* Mỗi class quan trọng có ít nhất 1 ảnh mẫu.
* Ảnh mẫu có license rõ ràng.
* Ảnh mẫu không quá nặng.
* Ảnh mẫu dùng được ngay trên trang demo.

---

# 8. Kiến trúc source code đề xuất

```text
plant-disease-demo/
  lib/
    main.dart
    app/
      app.dart
      router.dart
      theme.dart
    features/
      home/
      demo/
        presentation/
        application/
        domain/
      plant_library/
        presentation/
        application/
        domain/
      model_card/
      about/
    core/
      services/
        image_preprocess_service.dart
        inference_service.dart
        plant_data_service.dart
      models/
      widgets/
      utils/
  assets/
    model/
    data/
    images/
    sample_images/
  web/
  test/
  README.md
  vercel.json
```

## Interface quan trọng

Nên có abstraction cho inference:

```dart
abstract class InferenceService {
  Future<PredictionResult> predictImage(ImageInput input);
}
```

Lý do: sau này có thể đổi từ local model sang API backend mà không phải sửa toàn bộ UI.

---

# 9. Deployment Specification

## 9.1. Mục tiêu deploy

* Website public qua Vercel URL.
* Mỗi lần merge vào main sẽ deploy production.
* Pull request tạo preview deployment.
* Không cần người xem cài Flutter.
* Không cần clone GitHub.

## 9.2. Build command đề xuất

```bash
flutter build web --release
```

Output directory:

```text
build/web
```

Nếu Vercel build trực tiếp không ổn định do thiếu Flutter SDK, dùng GitHub Actions để build Flutter Web rồi deploy output lên Vercel.

## 9.3. Vercel configuration

`vercel.json` có thể dùng để cấu hình routing SPA:

```json
{
  "cleanUrls": true,
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

## 9.4. Environment variables

Nếu client-side inference thuần static:

* Không cần secret.
* Không cần backend env.

Nếu dùng backend API:

* `API_BASE_URL`
* `MAX_IMAGE_SIZE_MB`
* `SENTRY_DSN` nếu có
* Không đưa secret vào frontend.

## 9.5. Acceptance Criteria

* Website mở được bằng URL Vercel.
* Refresh ở route con không bị 404.
* Upload ảnh và detect chạy được trên production.
* Link GitHub hoạt động.
* Không có secret trong source public.
* Production build không còn debug banner.
* Website chạy được trên Chrome, Edge, Firefox.

---

# 10. Testing Plan

## 10.1. Unit Test

Cần test:

* Label mapping.
* Disease data parser.
* Image validation.
* Confidence formatter.
* Threshold logic.
* Inference result mapping.

Acceptance Criteria:

* Các hàm xử lý dữ liệu quan trọng có test.
* Không có label model bị thiếu mapping.
* Không có disease detail bị thiếu ID.

## 10.2. Manual Test

Checklist:

* Mở landing page.
* Bấm Try Demo.
* Upload ảnh hợp lệ.
* Upload ảnh sai định dạng.
* Upload ảnh quá lớn.
* Chọn ảnh mẫu.
* Detect thành công.
* Detect nhiều lần liên tiếp.
* Xem trang chi tiết bệnh.
* Search cây/bệnh.
* Mở trên mobile.
* Refresh route con.
* Mở bằng Firefox.

## 10.3. Model Regression Test

Cần có bộ ảnh test cố định:

```text
test_images/
  case_001_tomato_late_blight.jpg
  case_002_tomato_healthy.jpg
  case_003_potato_early_blight.jpg
```

Mỗi ảnh cần lưu expected label.

Acceptance Criteria:

* Web model cho kết quả khớp expected label ở các case chính.
* Nếu khác mobile app, phải ghi rõ nguyên nhân hoặc sai số chấp nhận được.
* Có log thời gian inference trung bình.

---

# 11. Giai đoạn triển khai

## Phase 0: Audit project hiện tại

### Mục tiêu

Kiểm tra app Flutter hiện tại có thể chuyển lên web đến mức nào.

### Việc cần làm

* Kiểm tra Flutter version.
* Kiểm tra app có web support chưa.
* Kiểm tra package nào không hỗ trợ web.
* Kiểm tra model đang dùng định dạng gì.
* Kiểm tra inference đang chạy bằng plugin nào.
* Kiểm tra data cây/bệnh đang lưu ở đâu.
* Kiểm tra assets có quá nặng không.
* Kiểm tra label mapping có rõ không.

### Deliverables

* Báo cáo audit ngắn.
* Danh sách package cần thay thế nếu không hỗ trợ web.
* Quyết định chọn client-side inference hay backend inference.
* Danh sách rủi ro.

### Acceptance Criteria

* Chạy được `flutter run -d chrome` hoặc biết rõ lý do chưa chạy được.
* Biết chính xác model format hiện tại.
* Biết chính xác pipeline preprocess.
* Biết danh sách package gây lỗi web nếu có.
* Có quyết định kiến trúc inference.

---

## Phase 1: Web skeleton + deploy Vercel lần đầu

### Mục tiêu

Có website Flutter Web chạy public, chưa cần AI hoàn chỉnh.

### Việc cần làm

* Thêm web support.
* Tạo landing page.
* Tạo routing.
* Tạo trang demo placeholder.
* Tạo trang plant/disease library placeholder.
* Build production.
* Deploy lên Vercel.
* Cấu hình rewrite cho SPA.

### Deliverables

* URL Vercel public.
* Landing page cơ bản.
* README có live demo link.

### Acceptance Criteria

* Website mở được qua URL.
* Refresh trang con không lỗi 404.
* UI responsive cơ bản.
* GitHub repo sạch, có README.
* Không có lỗi build production.

---

## Phase 2: Upload ảnh + preview + validation

### Mục tiêu

Người dùng upload ảnh được và xem preview.

### Việc cần làm

* Implement file picker.
* Implement drag & drop nếu có thể.
* Implement preview image.
* Implement remove image.
* Implement validation.
* Thêm ảnh mẫu.
* Thiết kế empty/loading/error states.

### Deliverables

* Trang demo upload ảnh hoàn chỉnh.
* Bộ ảnh mẫu.
* Validation message.

### Acceptance Criteria

* Upload JPG/PNG/WebP thành công.
* File sai định dạng bị từ chối.
* File quá lớn bị từ chối.
* Ảnh preview đúng.
* Chọn ảnh mẫu chạy được.
* Không crash khi thao tác sai.

---

## Phase 3: AI inference MVP

### Mục tiêu

Website nhận ảnh và trả kết quả dự đoán thật.

### Việc cần làm

* Port/chuyển model sang định dạng web hoặc tạo backend inference.
* Implement preprocess.
* Implement inference service.
* Implement label mapping.
* Hiển thị top-k results.
* Hiển thị confidence.
* So sánh output với mobile app trên bộ test.

### Deliverables

* Chức năng detect chạy thật.
* Model/data assets hoặc inference API.
* Test image set.
* Document preprocess.

### Acceptance Criteria

* Detect chạy được trên production.
* Kết quả không bị mismatch label.
* Có top 3 predictions.
* Có confidence rõ ràng.
* Có xử lý low-confidence.
* Có ít nhất 10 test images đã kiểm tra.
* Kết quả web gần tương đương mobile app trên test set.

---

## Phase 4: Plant/Disease Library hoàn chỉnh

### Mục tiêu

Giữ và nâng cấp tính năng xem thông tin cây trồng/bệnh cây.

### Việc cần làm

* Chuẩn hóa dữ liệu cây.
* Chuẩn hóa dữ liệu bệnh.
* Tạo list page.
* Tạo detail page.
* Tạo search/filter.
* Link kết quả dự đoán sang disease detail.
* Thêm nguồn tham khảo.

### Deliverables

* Plant library.
* Disease library.
* Disease detail pages.
* Data JSON chuẩn hóa.

### Acceptance Criteria

* Mọi label model đều map được sang thông tin bệnh/cây.
* Search hoạt động.
* Detail page có nội dung đầy đủ.
* Không có trang detail trống.
* Có nguồn tham khảo hoặc ghi chú nguồn.

---

## Phase 5: Portfolio polish

### Mục tiêu

Biến website từ “demo chạy được” thành “project đáng đưa vào CV”.

### Việc cần làm

* Tạo trang Model Card.
* Tạo trang Architecture/Tech Stack.
* Thêm GitHub link.
* Thêm screenshots.
* Thêm demo video ngắn nếu có.
* Thêm phần limitation.
* Thêm phần future improvements.
* Viết README chuyên nghiệp.

### Deliverables

* Model Card page.
* Architecture page.
* README hoàn chỉnh.
* Screenshots/demo video.

### Acceptance Criteria

* Người phỏng vấn hiểu project dùng công nghệ gì.
* Có số liệu model nếu có.
* Có limitation trung thực.
* Có architecture diagram.
* README đủ để review project.
* Website nhìn giống sản phẩm hoàn chỉnh, không giống bài tập dang dở.

---

## Phase 6: Quality, security, performance

### Mục tiêu

Đảm bảo website ổn định và không có lỗi cơ bản khi gửi cho nhà tuyển dụng.

### Việc cần làm

* Test trên Chrome, Edge, Firefox.
* Test mobile responsive.
* Test upload lỗi.
* Kiểm tra bundle size.
* Tối ưu ảnh.
* Lazy-load model.
* Thêm error logging nếu cần.
* Kiểm tra không lộ secret.
* Kiểm tra privacy note.
* Chạy Lighthouse.

### Deliverables

* QA checklist.
* Performance report ngắn.
* Danh sách lỗi đã fix.

### Acceptance Criteria

* Không crash trong flow chính.
* Không lộ secret.
* Không upload ảnh lên server nếu không cần.
* Có loading/error states.
* Performance ở mức chấp nhận được.
* UI không vỡ trên mobile.

---

## Phase 7: Final release

### Mục tiêu

Hoàn thiện bản public cuối cùng để đưa vào CV/GitHub/LinkedIn.

### Việc cần làm

* Gắn custom domain nếu có.
* Cập nhật README.
* Cập nhật CV với live demo link.
* Ghim repo trên GitHub.
* Thêm license.
* Thêm release tag.
* Viết mô tả project ngắn cho portfolio.
* Tạo video demo 30–60 giây.

### Deliverables

* Production URL.
* GitHub repo public.
* README final.
* Demo video.
* CV/portfolio updated.

### Acceptance Criteria

* Link live demo hoạt động.
* Repo GitHub dễ đọc.
* Có video/screenshot.
* Có mô tả rõ vai trò cá nhân.
* Có hướng dẫn chạy local.
* Có future improvements.

---

# 12. Những phần còn thiếu cần bổ sung

## 12.1. Thông tin về model

Cần bổ sung:

* Model hiện tại là gì?
* Định dạng model: `.tflite`, `.h5`, SavedModel, PyTorch, ONNX?
* Input size?
* Classes gồm những gì?
* Accuracy bao nhiêu?
* Train bằng dataset nào?
* Có confusion matrix không?
* Có test set riêng không?
* Model có chạy được trên web không?

Nếu thiếu phần này, website vẫn có thể đẹp nhưng khi phỏng vấn sẽ khó chứng minh năng lực AI.

---

## 12.2. Mapping giữa label model và nội dung hiển thị

Cần có file mapping rõ ràng.

Ví dụ vấn đề dễ gặp:

* Model trả về `Tomato___Late_blight`.
* UI lại hiển thị “Bệnh cháy lá”.
* Trang disease detail dùng ID khác.
* Kết quả dẫn đến sai thông tin.

Cần chuẩn hóa một ID duy nhất cho từng class.

---

## 12.3. Bộ ảnh test cố định

Cần ít nhất 10–30 ảnh test đại diện.

Mục tiêu:

* Kiểm tra model sau khi port lên web.
* So sánh mobile vs web.
* Demo nhanh khi không có ảnh thật.
* Tránh tình trạng deploy xong mới phát hiện model sai preprocess.

---

## 12.4. Nguồn dữ liệu cây/bệnh

Cần bổ sung nguồn cho thông tin:

* Triệu chứng.
* Nguyên nhân.
* Phòng ngừa.
* Hình ảnh minh họa.
* Tên khoa học.
* Cây bị ảnh hưởng.

Nếu không có nguồn, nên ghi rõ nội dung chỉ mang tính tham khảo.

---

## 12.5. Disclaimer về AI và nông nghiệp

Cần có cảnh báo:

* Kết quả chỉ là dự đoán của model.
* Không thay thế chuyên gia nông nghiệp.
* Ảnh thiếu sáng/mờ/sai góc có thể làm kết quả sai.
* Không nên dùng website làm căn cứ duy nhất để dùng thuốc/hoá chất.

Đây là điểm nhỏ nhưng làm project trông chuyên nghiệp và có trách nhiệm hơn.

---

## 12.6. Quyết định lưu hay không lưu ảnh

Cần quyết định rõ:

### Khuyến nghị cho MVP

Không lưu ảnh người dùng.

Lý do:

* Đơn giản.
* An toàn hơn.
* Ít vấn đề privacy hơn.
* Phù hợp demo tuyển dụng.

Nếu muốn lưu ảnh:

* Cần thông báo rõ.
* Cần storage.
* Cần xóa ảnh sau một thời gian.
* Cần tránh lưu dữ liệu không cần thiết.

---

## 12.7. Chiến lược inference

Đây là phần quan trọng nhất.

Cần trả lời:

* Model có đủ nhẹ để chạy trên browser không?
* Có thể convert sang TFJS/ONNX không?
* Nếu dùng TFLite, thư viện hiện tại có hỗ trợ web không?
* Nếu dùng backend, backend deploy ở đâu?
* Có bị giới hạn upload/timeout không?
* Có cần giữ model private không?

Khuyến nghị: thử client-side inference trước nếu model nhẹ. Nếu không ổn, chuyển sang backend FastAPI riêng.

---

## 12.8. Portfolio story

Cần viết rõ câu chuyện dự án:

* Vấn đề thực tế là gì?
* Vì sao chọn bài toán phát hiện bệnh lá cây?
* Dataset/model lấy từ đâu?
* Bạn tự làm những phần nào?
* Khó khăn kỹ thuật là gì?
* Bạn đã giải quyết thế nào?
* Nếu có thêm thời gian, bạn cải thiện gì?

Nhà tuyển dụng không chỉ xem app chạy được, họ muốn thấy cách bạn suy nghĩ và xử lý vấn đề.

---

# 13. Rủi ro chính và cách xử lý

## Risk 1: Flutter package hiện tại không hỗ trợ web

Cách xử lý:

* Audit dependencies.
* Thay package tương đương hỗ trợ web.
* Tách platform-specific code.
* Dùng conditional import nếu cần.

## Risk 2: Model TFLite không chạy trên web

Cách xử lý:

* Convert sang TFJS hoặc ONNX.
* Dùng WebAssembly runtime nếu phù hợp.
* Nếu không được, tạo backend inference bằng Python.

## Risk 3: Website tải quá chậm vì model lớn

Cách xử lý:

* Lazy-load model.
* Quantize model.
* Compress assets.
* Chỉ load model khi vào trang demo.
* Dùng backend inference nếu model quá lớn.

## Risk 4: Kết quả web khác mobile

Cách xử lý:

* Kiểm tra preprocess.
* Kiểm tra normalize.
* Kiểm tra input size.
* Kiểm tra label order.
* Dùng test set cố định.
* So sánh tensor đầu vào nếu cần.

## Risk 5: Upload ảnh qua Vercel Function bị lỗi dung lượng

Cách xử lý:

* Giới hạn ảnh dưới 3–5 MB.
* Resize ảnh client-side trước khi gửi.
* Dùng client-side inference để không cần upload.
* Nếu cần lưu, dùng direct upload storage.
* Nếu backend riêng, upload thẳng đến backend hoặc object storage.

## Risk 6: Demo nhìn giống app mobile bị ép lên web

Cách xử lý:

* Thiết kế lại layout cho desktop.
* Landing page riêng cho portfolio.
* Demo page rõ ràng.
* Thêm architecture/model card.
* Không chỉ bê nguyên giao diện mobile lên web.

---

# 14. Definition of Done

Dự án được xem là hoàn thành khi:

1. Website có URL public.
2. Nhà tuyển dụng có thể mở link và test ngay.
3. Upload ảnh hoạt động.
4. Model trả kết quả thật.
5. Có hiển thị confidence/top-k.
6. Có trang thông tin cây/bệnh.
7. Có trang model/tech stack.
8. Có README chuyên nghiệp.
9. Có GitHub link.
10. Không cần clone code để demo.
11. Không crash ở flow chính.
12. Không lộ secret.
13. Có disclaimer AI.
14. Có ảnh mẫu để test nhanh.
15. Có ít nhất một sơ đồ kiến trúc.
16. Có bộ test ảnh cố định.
17. Deploy production ổn định trên Vercel.

---

# 15. MVP ưu tiên làm trước

Thứ tự làm nên là:

1. Audit app hiện tại.
2. Build Flutter Web chạy được.
3. Deploy Vercel bản skeleton.
4. Làm upload + preview.
5. Làm inference chạy thật.
6. Làm result UI.
7. Làm plant/disease library.
8. Làm model card + README.
9. Tối ưu UI/performance.
10. Chốt bản portfolio.

Không nên bắt đầu bằng việc làm giao diện quá đẹp trước khi chắc chắn model chạy được trên web.

---

# 16. Kết luận kỹ thuật

Hướng tốt nhất cho bản demo tuyển dụng là deploy Flutter Web trên Vercel dưới dạng static website, ưu tiên inference trực tiếp trên browser nếu model đủ nhẹ và có thể convert. Cách này giúp người dùng test ngay, không cần backend, ít lỗi upload và phù hợp mục tiêu portfolio.

Nếu model hiện tại phụ thuộc nặng vào TFLite/native mobile hoặc Python runtime, nên giữ Vercel làm frontend và triển khai inference ở một backend riêng. Khi đó cần kiểm soát kỹ upload size, timeout, CORS, privacy và cold start.

Điều quan trọng nhất không phải chỉ là “chạy được trên web”, mà là website phải cho nhà tuyển dụng thấy rõ: bài toán, dữ liệu, model, pipeline xử lý ảnh, kiến trúc deploy, giới hạn thực tế và cách bạn ra quyết định kỹ thuật.
