import 'package:flutter/material.dart';
import 'package:tringo_vendor/Core/Const/app_color.dart';
import 'package:tringo_vendor/Core/Const/app_images.dart';

class  SubscriptionScreen  extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // Selected billing index: 0 = 1 Year, 1 = 6 Month, 2 = 3 Month
  int _selectedBilling = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F10) : const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          '',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              // Top crown + title
              Column(
                children: [
                  // Replace with your asset path
                  Image.asset(
                    AppImages.crown,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Unlock the Tringo’s",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    "Super Power",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Comparison Card
              _ComparisonCard(isDark: isDark),

              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Cancel Subscription Any time',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Billing options
              _BillingOptions(
                selected: _selectedBilling,
                onChanged: (i) => setState(() => _selectedBilling = i),
              ),

              const SizedBox(height: 16),

              // CTA Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF24B0FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Get Super Power Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF1A1B20) : Colors.white;
    final divider = isDark ? Colors.white10 : Colors.black12;

    final premiumGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF29D0FF), Color(0xFF227CFF)],
    );

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Row(
        children: [
          // Feature list + "Free" column
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header row



                // Features
                _FeatureRow(
                  text: 'Search engine visibility upto 5km',
                  free: true,
                ),
                _FeatureRow(
                  text: 'Unlimited Reply in Smart Connect',
                  free: false,
                ),
                _FeatureRow(
                  text: 'Reach your entire district',
                  free: false,
                ),
                _FeatureRow(
                  text: 'Search engine priority',
                  free: false,
                ),
                _FeatureRow(
                  text: 'Place 2 ads per month',
                  free: false,
                ),
                _FeatureRow(
                  text: 'Get Trusted Batch to gain clients',
                  free: false,
                ),
                _FeatureRow(
                  text: 'View Followers Picture',
                  free: false,
                  showBottomDivider: false,
                ),
              ],
            ),
          ),

          // Premium column
          Container(
            width: 84,
            height: 420,
            decoration: BoxDecoration(
              color: AppColor.iceBlue

            ),
            child: Column(
              children: const [
                SizedBox(height: 16),
                Text(
                  'Free',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                _Star(),

              ],
            ),
          ),
          Container(
            width: 84,
            height: 420,
            decoration: BoxDecoration(
              gradient: premiumGradient,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              children: const [
                SizedBox(height: 16),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _Star(),
                _Star(),
                _Star(),
                _Star(),
                _Star(),
                _Star(),
                _Star(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.text,
    required this.free,
    this.showBottomDivider = true,
  });

  final String text;
  final bool free;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = isDark ? Colors.white10 : Colors.black12;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feature text
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    height: 1.2,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

            ],
          ),
        ),

      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Icon(Icons.star_rounded, color: Colors.white),
    );
  }
}

class _BillingOptions extends StatelessWidget {
  const _BillingOptions({
    required this.selected,
    required this.onChanged,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _BillingChip(
            labelTop: '₹ 999',
            labelBottom: '1 Year',
            selected: selected == 0,
            onTap: () => onChanged(0),
            highlight: true,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BillingChip(
            labelTop: '₹ 759',
            labelBottom: '6 Month',
            selected: selected == 1,
            onTap: () => onChanged(1),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BillingChip(
            labelTop: '₹ 569',
            labelBottom: '3 Month',
            selected: selected == 2,
            onTap: () => onChanged(2),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _BillingChip extends StatelessWidget {
  const _BillingChip({
    required this.labelTop,
    required this.labelBottom,
    required this.selected,
    required this.onTap,
    this.highlight = false,
    required this.isDark,
  });

  final String labelTop;
  final String labelBottom;
  final bool selected;
  final bool highlight;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (isDark ? const Color(0xFF1F2635) : const Color(0xFFE9F5FF))
        : (isDark ? const Color(0xFF14161C) : Colors.white);
    final border = selected
        ? const Color(0xFF24B0FF)
        : (isDark ? const Color(0xFF2A2F3A) : const Color(0xFFE8EAF1));

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (highlight)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24B0FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Best',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Text(
                  labelTop,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              labelBottom,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
