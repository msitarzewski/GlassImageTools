# Toolbar, sidebar and inspector — October 21, 2026

State: complete — reviewed, tested, applied; Release 1.0 (24) installed and identity verified. Normal
launch awaits headset unlock (passcode required at installation and on recheck).

Objective: Owner requests after build 23: make toolbar Copy behave like Share › Copy (it showed a brief
modal); shrink sidebar previews to the height of their two text lines and widen the sidebar; review each
tool's inspector for nesting and UX; make Text and Pixelate add an object immediately instead of the
inspector's Add at Center; replace the + button and its import dropdown with one + menu styled like the
Shapes control. Report a new build.

Authorization: The owner's request covers the local edits, builds, tests and documentation; the
standing same-headset signing/install/normal-launch authorization applies. No Git, publication or
delegation. Work is staged in a private copy and compared with a hashed baseline before application.

Owners/reuse: `EditorModel` owns Copy state and tool use (`copying`, `useTool`); `ClipboardService`
owns the pasteboard write; `EditorView` owns the toolbar, + menu and focused command actions;
`EditorWindow` owns scene `EditorCommands`; `AnnotationInspector` owns per-kind forms; `DocumentSidebar`
owns rows; `ImageCanvas` keeps creation gestures. No new services, files beyond this record, or
dependencies.

## Findings and changes

| Request | Finding | Change |
|---|---|---|
| Copy differs from Share › Copy | Both wrote one `public.png` item. The brief modal was the editor-wide processing overlay; toolbar Copy alone set `.localOnly` | Copy runs without the overlay (`EditorModel.copying`, canvas status Copying…/Copied) and writes the same unrestricted item as Share › Copy, so Universal Clipboard now applies |
| Smaller previews, wider sidebar | Previews were fixed squares taller than the two lines | Previews measure the name/detail lines (1.4:1, aspect-filled, 6-point corners); sidebar 360 points (380 at accessibility sizes), was 320/340 |
| Inspector nesting/UX | Pane title "Options"/"Text" plus a second "Selected …" section title; stroke width split across two rows; Add at Center footer text; a "Crop" section under the "Crop" title | One title per pane (object name, "New …" for a tool's style, or a No Selection state); Text: Content and Style sections (Text Color with typography); shapes: Style with width label and slider in one row; Pixelate: Block Size with one footer; Position and Size, Arrange only for a selection; unnamed first crop group |
| Text/Pixelate add objects | Text needed a canvas tap; Pixelate a drag or Add at Center | Toolbar and Drawing Tools menu actions call `useTool`, placing a selected object at the crop center; canvas taps only select. The canvas accessibility action keeps the non-drag path for shapes |
| One + menu | + (new window) and a chevron menu (imports) were separate | One + menu (`new-image-menu`) styled like Shapes: New Window, Choose from Photos…, Import from Files…, Paste |

### Found during QA

- **⌘N lost (introduced, fixed) and ⌘, never registered.** Moving New Window into a menu dropped its
  shortcut, and the ornament Settings shortcut was never registered. Scene `EditorCommands` now own ⌘N
  and ⌘, through the focused window's actions; simulator key events open a window and Settings.
- **⌘V image paste does not work (not fixed).** `PasteButton`'s shortcut was not honored in empty or
  document windows, in this build or before. Replacing the system Paste command would break text-field
  paste, so documentation no longer claims ⌘V; + › Paste works.
- **No Selection header floated mid-pane (introduced, fixed)** by filling the pane.
- **Sidebar row layout loop at accessibility sizes (introduced, fixed).** A wrapping detail line made the
  measured height grow, widening the preview until the name collapsed to zero width. Both lines are now
  single-line, so height does not depend on the remaining width.
- **Inspector reveal helper (test, fixed).** Synthesized swipes that begin on a color well, slider or
  toggle row can leave a Form unscrolled, and the Form's center became the Fill toggle once tests drew
  shapes instead of using Add at Center. Build 23 behaves identically when a shape is drawn. The shared
  helper now tries the Form, then visible rows from the bottom up, until the rows move.
- **Stale UI test geometry (test, fixed).** Text now sits at the crop center, so the old "empty canvas"
  hold point fell inside the text object's 30-point hit margin and correctly opened its menu; the hold
  now targets canvas above the object. The tiny-shape test dragged the top-left handle to
  `canvas-test-start`, which is the drawn shape's own corner, collapsing it; the test now moves the tiny
  shape to the build-23 Add at Center origin first. Coordinate press-drags from a handle move the object
  instead of resizing it in builds 23 and 24 alike, so handle tests keep element-to-element drags.
- **Compiler warning (fixed):** a never-mutated `weak var` in a Debug check is now `weak let`.
- **Process slip (corrected):** one documentation append landed in the workspace instead of the stage; the
  pre-application hash check caught it, the text moved to the stage and the workspace file was restored to
  its baseline bytes before application.

## Validation

| Check | Result |
|---|---|
| Core | 67 tests / 5 suites pass, 0.816 s, exit 0 (core unchanged) |
| Native services | 50 / 50 pass, including "Text and Pixelate place objects" and "Copy does not block editing" |
| First full UI run | Stopped after 10 cases: 2 inspector-reveal failures (largest text, sheets/text audit) |
| Second full UI run | 35 / 37 (exit 65, 1,174 s): stale empty-canvas hold point and collapsing handle-drag destination |
| Final full UI suite | **37 / 37, exit 0, 1,173 s** on the final applied source |
| Baseline comparisons | Build 23 shows the same post-draw swipe and coordinate-drag behavior |
| Keyboard | ⌘N (empty and document windows) and ⌘, observed with simulator key events; ⌘V image paste not observed |
| Compositor | Largest-text sidebar row, No Selection header at the top, + menu items |
| Signed Release | build + analyze exit 0 (25 s); strict signature; Glass Image Tools 1.0 (24), family 7; add-only Photos only; no Debug markers; two expected AppIntents skips |
| Capture probe | Device-SDK compile exit 0 (compilation only) |
| Application | 27 files; no baseline conflicts; workspace matches stage (123 files) |
| Headset | Install exit 0 (2.0 s); identity 1.0 (24); passcode required, so no launch attempt |

Limits: simulator automation/compositor evidence plus installation and identity. Normal launch and the
running process await unlock. Universal Clipboard delivery to the owner's other devices, gaze/hand use of
the + menu and inspector, hardware-keyboard ⌘N/⌘, and assistive technology remain owner observations.
⌘V image paste is not available.

[Sanitized evidence](../Documentation/Validation/toolbar-sidebar-and-inspector.json),
[physical history](../Documentation/Validation/physical-deployment.json).
