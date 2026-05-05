import 'package:flutter/material.dart';

class ContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Body(),
                  FooterWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Icon(Icons.blur_circular, size: 28),
              SizedBox(width: 8),
              Text(
                "logo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          // Menu (ẩn nếu màn nhỏ)
          Spacer(),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                return Icon(Icons.menu);
              }
              return Row(
                children: [
                  _menuItem("Products"),
                  _menuItem("Solutions"),
                  _menuItem("Community"),
                  _menuItem("Resources"),
                  _menuItem("Pricing"),
                  _menuItem("Contact"),
                ],
              );
            },
          ),

          // Buttons
          Row(
            children: [
              TextButton(onPressed: () {}, child: Text("Sign in")),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text("Register"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  final List<Map<String, String>> products = [
    {
      "title": "Sản phẩm 1",
      "desc": "Mô tả sản phẩm 1",
      "image": "assets/images/avt-shin.jpg"
    },
    {
      "title": "Sản phẩm 2",
      "desc": "Mô tả sản phẩm 2",
      "image": "assets/images/avt-shin.jpg"
    },
    {
      "title": "Sản phẩm 3",
      "desc": "Mô tả sản phẩm 3",
      "image": "assets/images/avt-shin.jpg"
    },
    {
      "title": "Sản phẩm 4",
      "desc": "Mô tả sản phẩm 4",
      "image": "assets/images/avt-shin.jpg"
    },
    {
      "title": "Sản phẩm 5",
      "desc": "Mô tả sản phẩm 5",
      "image": "assets/images/avt-shin.jpg"
    },
    {
      "title": "Sản phẩm 6",
      "desc": "Mô tả sản phẩm 6",
      "image": "assets/images/avt-shin.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          //Banner
          Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/avt-shin.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Title",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Chào mọi người",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 40),

          // 2 sản phẩm ngang
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(child: _productCard()),
                SizedBox(width: 20),
                Expanded(child: _productCard()),
              ],
            ),
          ),

          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Heading
                Text(
                  "Heading",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),

                /// Subheading
                Text(
                  "Subheading",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 24),

                /// Danh sách các thẻ nằm dọc
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 3, // (có thể đổi thành products.length)
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _listCard(
                        title: "Title",
                        desc:
                            "Body text for whatever you’d like to say. Add main takeaway points, quotes, anecdotes, or even a very very short story.",
                        image: products[index]["image"]!,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 40),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Heading
                  Text(
                    "Heading",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),
                  Text(
                    "Subheading",
                    style: TextStyle(color: Colors.grey),
                  ),

                  SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return _gridCard(
                        title: p["title"]!,
                        desc: p["desc"]!,
                        image: p["image"]!,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40),
        ],
      );
  }

  /// 🔹 Card ngang nhỏ
  Widget _productCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage('assets/images/avt-shin.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  Widget _listCard({
    required String title,
    required String desc,
    required String image,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Ảnh bên trái
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Background xám giống ảnh placeholder
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: AssetImage(image), // Ảnh thật thay thế cho placeholder
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 24),

          /// Nội dung bên phải
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4, // Tạo khoảng cách dòng (line-height) đẹp hơn
                  ),
                ),
                SizedBox(height: 16),
                /// Nút Button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    "Button",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Card grid
  Widget _gridCard({
    required String title,
    required String desc,
    required String image,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Ảnh
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(height: 12),

          /// Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          /// Description
          Text(
            desc,
            style: TextStyle(color: Colors.grey),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double widthAuto = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    bool isMobile = widthAuto < 600;
    bool isTablet = widthAuto >= 600 && widthAuto < 1000;
    bool isDesktop = widthAuto >= 1000;

    // Tính toán kích thước cột dựa vào chiều rộng
    double columnWidth;
    if (isMobile) {
      columnWidth = (widthAuto - 80) / 2; // 2 cột cho mobile
    } else if (isTablet) {
      columnWidth = (widthAuto - 100) / 3; // 3 cột cho tablet
    } else {
      columnWidth = 150; // 4 cột cố định cho desktop
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 40,
      ),
      child: Wrap(
        runSpacing: 40,
        spacing: isMobile ? 20 : 40,
        alignment: WrapAlignment.spaceBetween,
        children: [
          /// CỘT 1: Logo và Mạng xã hội
          SizedBox(
            width: columnWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo (Thay thế bằng file ảnh logo của bạn)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bubble_chart, // Placeholder Logo
                    size: 32,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Các icon mạng xã hội
                Row(
                  children: [
                    _socialIcon(Icons.close, 'https://twitter.com'), // X (Twitter)
                    const SizedBox(width: 16),
                    _socialIcon(Icons.camera_alt_outlined, 'https://instagram.com'), // Instagram
                    const SizedBox(width: 16),
                    _socialIcon(Icons.play_circle_outline, 'https://youtube.com'), // YouTube
                    const SizedBox(width: 16),
                    _socialIcon(Icons.business, 'https://linkedin.com'), // LinkedIn
                  ],
                ),
              ],
            ),
          ),

          /// CỘT 2: Use cases
          SizedBox(
            width: columnWidth,
            child: _buildFooterColumn(
              title: "Use cases",
              links: [
                "UI design",
                "UX design",
                "Wireframing",
                "Diagramming",
                "Brainstorming",
                "Online whiteboard",
                "Team collaboration",
              ],
            ),
          ),

          /// CỘT 3: Explore
          SizedBox(
            width: columnWidth,
            child: _buildFooterColumn(
              title: "Explore",
              links: [
                "Design",
                "Prototyping",
                "Development features",
                "Design systems",
                "Collaboration features",
                "Design process",
                "FigJam",
              ],
            ),
          ),

          /// CỘT 4: Resources
          SizedBox(
            width: columnWidth,
            child: _buildFooterColumn(
              title: "Resources",
              links: [
                "Blog",
                "Best practices",
                "Colors",
                "Color wheel",
                "Support",
                "Developers",
                "Resource library",
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget để tạo icon mạng xã hội
  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () {
        // TODO: Gắn link vào đây - Có thể dùng url_launcher package
        // launchUrl(Uri.parse(url));
        print('Mở link: $url');
      },
      child: Icon(
        icon,
        size: 24,
        color: Colors.black87,
      ),
    );
  }

  /// Helper widget để tạo danh sách link cho từng cột
  Widget _buildFooterColumn({required String title, required List<String> links}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề cột
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 24),
        
        // Danh sách các link
        ...links.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                // Xử lý sự kiện khi click vào link
              },
              child: Text(
                link,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87, // Màu chữ xám đen giống thiết kế
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
// Widget menu có hover
class _menuItem extends StatefulWidget {
  final String title;
  const _menuItem(this.title);

  @override
  State<_menuItem> createState() => _menuItemState();
}

class _menuItemState extends State<_menuItem> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          widget.title,
          style: TextStyle(
            color: isHover ? Colors.black : Colors.grey,
            fontWeight: isHover ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
