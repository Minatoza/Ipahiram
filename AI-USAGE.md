# AI Usage — Ipahiram

**AI Assistant Used:** Claude (Anthropic)
**Repository:** https://github.com/Minatoza/Ipahiram

---

## 1. How I used AI

### 2026-09-27 — Core app structure
- **Tool:** Claude (Anthropic)
- **What I asked for:** Help structuring a Loan model, a repository for persisting loans, and the first two screens (Home, New Loan).
- **What it gave back:** A `ChangeNotifier`-based repository saving one JSON list to `shared_preferences`, and a `Loan` model with a computed `isOverdue` getter.
- **What I kept, what I changed, and why:** I kept the repository pattern, but changed the status badge — the AI's first version followed my written design doc (a plain overdue/not-overdue flag), which didn't match my own mockup's three states. I rewrote it to compute Overdue/Due today/Due in Nd from the due date instead.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/751784e

### 2026-09-28 — Item Detail, History, navigation
- **Tool:** Claude (Anthropic)
- **What I asked for:** The screens my Week 1 code had left as stubs — viewing a loan, marking it returned, a history list, and tabs to switch between them.
- **What it gave back:** `ItemDetailScreen` looking up a loan by id through a `ListenableBuilder`, a `HistoryScreen`, and a `RootShell` holding the tab bar.
- **What I kept, what I changed, and why:** I kept the structure, but integrating it into my existing `home_screen.dart` broke twice on my end — once from pasting a new `onTap` into the wrong widget, once from a full-file paste that dropped two classes I still needed. Both were my mistakes in applying the code, not issues with the code itself, and I fixed both by reading the analyzer errors and matching them back to the actual file.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/d0807a5

### 2026-10-03 — Edit Loan
- **Tool:** Claude (Anthropic)
- **What I asked for:** A way to edit a saved loan, after noticing `copyWith` had no way to clear a note once set.
- **What it gave back:** A `clearNote` flag on `copyWith`, since passing `note: null` can't be told apart from "leave it alone" in Dart.
- **What I kept, what I changed, and why:** Kept it as given — this one matched what I needed on the first pass.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/ebec191

### 2026-10-03 — Reminder notification
- **Tool:** Claude (Anthropic)
- **What I asked for:** The due-date reminder from my proposal, scoped so it does nothing on web and reschedules from saved data when the app restarts.
- **What it gave back:** A `NotificationService` using `flutter_local_notifications`, guarded by `kIsWeb` in every method.
- **What I kept, what I changed, and why:** Kept the structure. One parameter in the first version (`uiLocalNotificationDateInterpretation`) no longer exists in the plugin version I actually have installed — `flutter analyze` caught it immediately and I removed it.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/495dd8f

### 2026-10-04 — Item photo
- **Tool:** Claude (Anthropic)
- **What I asked for:** Letting a user attach a photo of the item, shown the same way on Home, Item Detail, and History.
- **What it gave back:** A base64-in-JSON approach, reusing my existing `shared_preferences` storage instead of adding file-based storage (which doesn't work on web at all).
- **What I kept, what I changed, and why:** Kept it — the reasoning made sense given I only have a web dev environment, and it meant one code path instead of two.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/2783130

---

## 2. Where the AI got it wrong

### Case 1 — Instruction didn't say which widget
- **What it gave me:** "Replace the card's onTap" with no file location beyond the filename, in a file that had several tap handlers.
- **What was wrong with it:** I put the new code after the floating action button instead of inside `LoanCard`. `flutter analyze` failed with "No named parameter 'onTap'" because the widget I'd pasted it into doesn't take one.
- **What I did instead:** Matched the error to the actual widget tree and moved the code into `LoanCard` inside the list.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/9b41b9a

### Case 2 — Full-file replacement dropped existing classes
- **What it gave me:** A rewritten top half of `home_screen.dart`, meant to be pasted whole.
- **What was wrong with it:** Two private widget classes lower in the same file (`_ItemsOutPill`, `_DashedRRectPainter`) weren't included, so pasting it as a full replacement deleted them.
- **What I did instead:** Pulled both classes back from the previous version of the file and appended them below.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/9b41b9a

### Case 3 — Outdated plugin API
- **What it gave me:** A notification-scheduling call using a parameter from an older version of `flutter_local_notifications`.
- **What was wrong with it:** That parameter doesn't exist in the version in my `pubspec.yaml`. The analyzer flagged it as undefined.
- **What I did instead:** Removed it — the current API schedules correctly without it.
- **Commit:** https://github.com/Minatoza/Ipahiram/commit/495dd8f

---

## 3. Who wrote what

### Written by me

**File:** `lib/widgets/loan_status_badge.dart` (three-state status logic)
**Commit:** https://github.com/Minatoza/Ipahiram/commit/751784e
**What it does and why it is built this way:** My written design-system plan specced a plain overdue/not-overdue flag, but my own mockup shows three states. I caught the mismatch by comparing the running app against the mockup, and decided the badge should take the whole `Loan` object and compute "Overdue" / "Due today" / "Due in Nd" directly from the due date, rather than storing a separate status field that could go stale if the due date changed later — which matters, since Extend Due Date lets exactly that happen.

**File:** `lib/screens/home_screen.dart` (integration fixes)
**Commit:** https://github.com/Minatoza/Ipahiram/commit/9b41b9a
**What it does and why it is built this way:** I found and fixed both mistakes in Case 1 and Case 2 above myself — tracing the analyzer's error text back to the specific widget or missing class, rather than asking for new code to fix it.

**File:** `lib/widgets/photo_picker_field.dart` (photo source bottom sheet)
**Commit:** https://github.com/Minatoza/Ipahiram/commit/92399ed
**What it does and why it is built this way:** Rather than defaulting straight to the gallery or the camera, I used a bottom sheet so the user picks which one each time, and added a "Remove photo" option that only appears when `photoBase64 != null` — checked with a simple conditional inside the sheet's children list, so the remove option never shows for a loan that has no photo yet. I chose a bottom sheet over separate buttons because it matches the dark `AppColors.surface` card style already used everywhere else in the app, instead of introducing a different UI pattern just for this one screen.

### The AI-written part I understand best

**File:** `lib/screens/item_detail_screen.dart`
**Commit:** https://github.com/Minatoza/Ipahiram/commit/d0807a5
**What it does and why we kept it:** It takes a loan's id, not the loan itself, and looks it up fresh from the repository inside a `ListenableBuilder` on every rebuild. That's why extending a due date from this screen shows the new date immediately — the repository calls `notifyListeners()` after saving, which triggers the lookup again. The return/extend/edit buttons are wrapped in `if (loan.isActive)`, so once a loan is marked returned, the next rebuild removes them without needing a separate flag for "is this read-only now."

Link to README.md AI Credit: https://github.com/Minatoza/Ipahiram/blob/main/README.md#ai-use