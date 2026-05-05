import 'package:flutter/material.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. THANH ĐIỀU HƯỚNG HEADER (Products, Solutions...)
            _buildWebHeader(),

            // Để nội dung không bị sát mép màn hình, ta bọc trong Padding
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. PHẦN HERO (Title, Subtitle, 2 hộp to)
                  _buildHeroSection(),
                  const SizedBox(height: 60),

                  // 3. PHẦN DANH SÁCH 3 THẺ DỌC
                  _buildListSection(),
                  const SizedBox(height: 60),

                  // 4. PHẦN LƯỚI 3 CỘT (3 cái ngang hàng)
                  _buildGridSection(),
                ],
              ),
            ),

            // 5. CHÂN TRANG 4 CỘT DÀN NGANG ĐỀU NHAU
            _buildWebFooter(),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HEADER DẠNG WEB
  // ==========================================
  Widget _buildWebHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.grid_view_rounded, size: 32),
            const SizedBox(width: 40),
            _headerLink("Products"),
            _headerLink("Solutions"),
            _headerLink("Community"),
            _headerLink("Resources"),
            _headerLink("Pricing"),
            _headerLink("Contact"),
            const SizedBox(width: 40),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                side: BorderSide.none,
                foregroundColor: Colors.black,
              ),
              child: const Text("Sign in"),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // ==========================================
  // WIDGET HERO SECTION
  // ==========================================
  Widget _buildHeroSection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Center(
          child: Text(
            "Title",
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Subtitle",
            style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 60),
        Row(
          children: [
            Expanded(child: _buildPlaceholder(height: 300)),
            const SizedBox(width: 24),
            Expanded(child: _buildPlaceholder(height: 300)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // WIDGET LIST SECTION (Thẻ có ảnh bên trái, chữ bên phải)
  // ==========================================
  Widget _buildListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Heading",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Subheading",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        ...List.generate(3, (index) => _buildWideCard()),
      ],
    );
  }

  Widget _buildWideCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlaceholder(width: 120, height: 120),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Title",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Body text for whatever you'd like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    side: BorderSide.none,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Button"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET GRID SECTION (Lưới 3 cột)
  // ==========================================
  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Heading",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Subheading",
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // CHÍNH XÁC 3 CỘT NGANG HÀNG
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 0.8, // Chỉnh tỷ lệ khung hình
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildGridCard();
          },
        ),
      ],
    );
  }

  Widget _buildGridCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildPlaceholder(width: double.infinity)),
          const SizedBox(height: 16),
          const Text(
            "Title",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Body text for whatever you'd like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET FOOTER (Đã cập nhật Expanded để chia đều tăm tắp 4 cột)
  // ==========================================
  Widget _buildWebFooter() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Row(
        // Thay Wrap bằng Row
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột 1: Logo & Icons (Chiếm 1 phần)
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.grid_view_rounded, size: 32),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.close, size: 20), // Placeholder cho icon X
                    SizedBox(width: 16),
                    Icon(Icons.camera_alt_outlined, size: 20),
                    SizedBox(width: 16),
                    Icon(Icons.play_circle_outline, size: 20),
                    SizedBox(width: 16),
                    Icon(Icons.business_center, size: 20), // LinkedIn
                  ],
                ),
              ],
            ),
          ),

          // Cột 2 (Chiếm 1 phần)
          Expanded(
            flex: 1,
            child: _buildFooterCol("Use cases", [
              "UI design",
              "UX design",
              "Wireframing",
              "Diagramming",
              "Brainstorming",
              "Online whiteboard",
              "Team collaboration",
            ]),
          ),

          // Cột 3 (Chiếm 1 phần)
          Expanded(
            flex: 1,
            child: _buildFooterCol("Explore", [
              "Design",
              "Prototyping",
              "Development features",
              "Design systems",
              "Collaboration features",
              "Design process",
              "FigJam",
            ]),
          ),

          // Cột 4 (Chiếm 1 phần)
          Expanded(
            flex: 1,
            child: _buildFooterCol("Resources", [
              "Blog",
              "Best practices",
              "Colors",
              "Color wheel",
              "Support",
              "Developers",
              "Resource library",
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterCol(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              link,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HÀM HỖ TRỢ: VẼ KHUNG ẢNH XÁM
  // ==========================================
  Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
          size: 40,
        ),
      ),
    );
  }
}
