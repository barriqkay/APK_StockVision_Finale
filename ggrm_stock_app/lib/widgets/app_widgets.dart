import 'package:flutter/material.dart';
import '../theme.dart';

/// ==========================================
/// Enhanced Custom Button Widget
/// ==========================================
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool isLoading;
  final bool isDisabled;
  final List<BoxShadow>? boxShadow;
  final TextStyle? textStyle;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 52,
    this.borderRadius = AppRadius.medium,
    this.fontSize = 16,
    this.isLoading = false,
    this.isDisabled = false,
    this.boxShadow,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = foregroundColor ?? Colors.white;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: boxShadow ?? AppShadows.medium,
      ),
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null ? BorderSide(color: borderColor!) : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 20),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: textStyle ?? TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: fontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: AppSpacing.sm),
                    Icon(trailingIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// ==========================================
/// Glassmorphism Card Widget
/// ==========================================
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final bool showBorder;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding,
    this.borderRadius = AppRadius.large,
    this.showBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppShadows.card,
        border: showBorder ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}

/// ==========================================
/// Gradient Container Widget
/// ==========================================
class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientContainer({
    Key? key,
    required this.child,
    this.colors = AppColors.primaryGradient,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}

/// ==========================================
/// Stock Price Card Widget
/// ==========================================
class StockPriceCard extends StatelessWidget {
  final String ticker;
  final String companyName;
  final String price;
  final String change;
  final double changePercent;
  final VoidCallback? onTap;

  const StockPriceCard({
    Key? key,
    required this.ticker,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercent,
    this.onTap,
  }) : super(key: key);

  bool get isPositive => changePercent >= 0;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(Icons.trending_up, color: AppColors.primary, size: 28),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticker, style: AppTextStyles.titleLarge),
                    Text(companyName, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Harga Saat Ini', style: AppTextStyles.labelMedium),
                  Text(price, style: AppTextStyles.priceLarge),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.bullish : AppColors.bearish).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isPositive ? AppColors.bullish : AppColors.bearish,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: isPositive ? AppColors.bullish : AppColors.bearish,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ==========================================
/// Prediction Result Card
/// ==========================================
class PredictionCard extends StatelessWidget {
  final String predictedPrice;
  final String change;
  final double changePercent;
  final String confidence;
  final String lastUpdate;

  const PredictionCard({
    Key? key,
    required this.predictedPrice,
    required this.change,
    required this.changePercent,
    required this.confidence,
    required this.lastUpdate,
  }) : super(key: key);

  bool get isPositive => changePercent >= 0;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text('Prediksi Besok', style: AppTextStyles.titleMedium),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text('Harga Prediksi', style: AppTextStyles.labelMedium),
          Text(
            predictedPrice,
            style: AppTextStyles.priceMedium.copyWith(color: AppColors.primary),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perubahan', style: AppTextStyles.labelMedium),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? AppColors.bullish : AppColors.bearish,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Persentase', style: AppTextStyles.labelMedium),
                    Text(
                      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? AppColors.bullish : AppColors.bearish,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.textLight),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Kepercayaan: $confidence | Update: $lastUpdate',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ==========================================
/// Quick Action Button
/// ==========================================
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: AppShadows.small,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ==========================================
/// Info Row Widget
/// ==========================================
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// ==========================================
/// Section Header
/// ==========================================
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionText,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.titleLarge),
        ),
        if (actionText != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionText!,
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}

/// ==========================================
/// Loading Shimmer Card
/// ==========================================
class ShimmerCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const ShimmerCard({Key? key, this.height = 120, this.borderRadius = AppRadius.large})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

