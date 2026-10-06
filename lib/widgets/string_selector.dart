import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_chepita_afinador/models/instrument_string.dart';
import 'package:app_chepita_afinador/theme/app_theme.dart';

class StringSelectorRow extends StatelessWidget {
  final List<InstrumentString> strings;
  final InstrumentString selectedString;
  final bool isAutoMode;
  final ValueChanged<InstrumentString> onSelectString;
  final VoidCallback onToggleAuto;

  const StringSelectorRow({
    super.key,
    required this.strings,
    required this.selectedString,
    required this.isAutoMode,
    required this.onSelectString,
    required this.onToggleAuto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        children: [
          // Barra de cabecera con selector Auto / Manual
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CUERDAS DEL UKELELE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggleAuto();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAutoMode
                        ? AppTheme.tuned.withValues(alpha: 0.15)
                        : AppTheme.surfaceHighlight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isAutoMode ? AppTheme.tuned : AppTheme.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAutoMode ? Icons.auto_awesome_rounded : Icons.touch_app_rounded,
                        size: 13,
                        color: isAutoMode ? AppTheme.tuned : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAutoMode ? 'MODO AUTO' : 'MODO MANUAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isAutoMode ? AppTheme.tuned : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Botones individuales para cada una de las 4 cuerdas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: strings.map((instrumentString) {
              final isSelected = selectedString.id == instrumentString.id;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelectString(instrumentString);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.surfaceHighlight
                            : AppTheme.surfaceContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.tuned : AppTheme.border.withValues(alpha: 0.5),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.tunedGlow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${instrumentString.stringIndex}ª',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppTheme.tuned : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            instrumentString.id,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            instrumentString.noteName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
