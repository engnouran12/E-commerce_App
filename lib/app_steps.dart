/* 
focus on ui only and responsive
api:DummyJSON Products docs:https://dummyjson.com/docs/products
figma:https://www.figma.com/design/FefgWQMXZWs1wiMEiwvy0e/Lafyuu-E-commerce-UI-Kit-for-Figma--Community-?node-id=35-0&t=kaL8RmaSA9K0GVcB-1
1)folder strucure MVVM feature first layer desiction
lib/
main.dart
core/
theme/
app_colors.dart
app_text_styles.dart
app_spacing.dart
app_theme.dart
responsive/
breakpoints.dart
widgets/ (shared widgets, empty for now)
constants/ (empty for now)
features/
products/
data/
models/
product_model.dart
datasources/
products_sample_data.dart
presentation/
view_models/
products_view_model.dart
views/
products_view.dart
widgets/
product_card.dart
2) setup figma styles,colors,fonts,theme in core folder,assets
3)create core widgets that on ui guidelines (buttons,textfields,cards etc)
4) ui home screen in product feature that reuse component of widgets in core and make screen divides  by component of feature name like cat,product

*/