# Provider UI Redesign

## Goal
Redesign the Chat and Image provider test pages for better space utilization, tighter workflow, and refined visuals within the PersonaPanel design system.

## Scope
- `provider_detail_page.dart` (Chat test page)
- `image_provider_detail_page.dart` (Image test page)
- Settings list page NOT in scope

## Requirements

### 1. Remove command bar, integrate status into header
- Remove `_ProviderCommandBar` and `_ImageProviderCommandBar`
- Connection test status: badge next to title
- Enabled/disabled: toggle in actions area
- baseUrl + model count: in description

### 2. Collapsible sidebar (both pages)
- Expanded: 410px, retains Prompt/Params/Request tabs (chat) or Params/Request/Response tabs (image)
- Collapsed: 0px hidden, smooth AnimatedContainer transition
- Toggle button in inline control bar
- State managed via StatefulWidgets

### 3. Inline control bar in workbench header
- Chat: model dropdown (compact) + temperature slider (compact with label) + sidebar toggle
- Image: model dropdown + sidebar toggle
- Always visible, below workbench section header

### 4. Chat workbench refinements
- Remove fixed 700px height, use dynamic sizing (MediaQuery or LayoutBuilder)
- Refined bubble styling: user messages with person icon, assistant with smart_toy icon
- Typing cursor animation during streaming (blinking |)
- Skeleton shimmer loading state for assistant bubble

### 5. Image workbench refinements
- Remove fixed 760px height, preview area expands with Expanded
- Inline parameter chips above preview: aspect ratio, size, quality as ChoiceChip/SegmentedButton
- Input area pinned to bottom

### 6. Responsive behavior
- 980px breakpoint: below stacks vertically (workbench top, sidebar bottom)
- Inline controls always visible

## Not Changing
- Riverpod state management
- Freezed models
- GoRouter routing
- PersonaPage/PersonaPanel public API
