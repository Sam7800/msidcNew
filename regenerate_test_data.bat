@echo off
echo Regenerating test data with new status examples...
echo.
dart run lib/scripts/create_test_data.dart
echo.
echo Test data regeneration complete!
echo You can now run the app and see the color-coded status cards.
pause
