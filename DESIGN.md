---
version: alpha
name: Rememberly
description: A mobile reading companion that pairs soft editorial typography with calm iOS-native utility.
colors:
  background: "#F6F8FA"
  background-strong: "#F3F5F7"
  surface: "#FFFFFF"
  surface-muted: "#F6F8FA"
  surface-overlay: "#FFFFFF"
  text-primary: "#36394A"
  text-secondary: "#666D80"
  text-muted: "#36394A"
  text-subdued: "#818898"
  text-loud: "#0D0D12"
  icon-default: "#404040"
  border-subtle: "#ECEFF3"
  border-strong: "#DFE1E7"
  button-dark: "#1B1D20"
  accent-gold: "#EBC658"
  accent-success: "#4CB14F"
  badge-rose: "#DBC1C1"
  camera-base: "#000000"
  book-blue: "#408FF7"
  book-blue-ink: "#26668F"
  book-red: "#D95A52"
  book-red-ink: "#9E6055"
  book-yellow: "#F2C74D"
  book-yellow-ink: "#998053"
  book-purple: "#9E82D9"
  book-purple-ink: "#535C99"
  book-green: "#6BB86B"
  book-green-ink: "#789953"
  gradient-book-pink-start: "#FFE0E0"
  gradient-book-pink-end: "#EC9F9F"
  gradient-book-gold-start: "#FFF5E3"
  gradient-book-gold-end: "#EBD09D"
  gradient-profile-start: "#BFAAFD"
  gradient-profile-end: "#A080F5"
typography:
  title-hero:
    fontFamily: SF Pro
    fontSize: 32px
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: -0.02em
  title-screen:
    fontFamily: New York
    fontSize: 24px
    fontWeight: 500
    lineHeight: 1.2
    letterSpacing: -0.02em
  title-section:
    fontFamily: SF Pro
    fontSize: 22px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: -0.02em
  title-card:
    fontFamily: New York
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.35
    letterSpacing: -0.01em
  body-editorial:
    fontFamily: New York
    fontSize: 18px
    fontWeight: 400
    lineHeight: 1.78
    letterSpacing: 0em
  body-regular:
    fontFamily: SF Pro
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 0em
  body-compact:
    fontFamily: SF Pro
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: 0em
  label-button:
    fontFamily: SF Pro
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1
    letterSpacing: 0em
  label-caption:
    fontFamily: SF Pro
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.25
    letterSpacing: 0em
  label-badge:
    fontFamily: New York
    fontSize: 12px
    fontWeight: 600
    lineHeight: 1
    letterSpacing: 0em
  monogram-book:
    fontFamily: New York
    fontSize: 28px
    fontWeight: 400
    lineHeight: 1
    letterSpacing: 0em
rounded:
  xs: 4px
  sm: 6px
  md: 8px
  lg: 10px
  xl: 16px
  "2xl": 18px
  "3xl": 22px
  "4xl": 24px
  "5xl": 32px
  full: 9999px
spacing:
  xxs: 2px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  "2xl": 24px
  "3xl": 28px
  "4xl": 32px
  "5xl": 40px
  "6xl": 48px
  screen-margin: 20px
  section-gap: 32px
  card-padding: 16px
  input-padding-x: 12px
  input-padding-y: 11px
elevation:
  flat: none
  subtle-border: 1px solid {colors.border-subtle}
  card: 0 1px 0 rgba(9, 25, 72, 0.13), 0 1px 1px rgba(18, 55, 105, 0.08)
  floating: 0 1px 1px rgba(0, 0, 0, 0.08), 0 4px 12px rgba(0, 0, 0, 0.12)
  media: 0 2px 4px rgba(0, 0, 0, 0.10)
  camera-stage: 0 8px 18px rgba(0, 0, 0, 0.26)
motion:
  instant: 150ms
  quick: 200ms
  standard: 250ms
  emphasis: 300ms
  spring-soft: spring(0.4, 0.75)
  ease-standard: ease-in-out
  ease-exit: ease-out
shadows:
  button: 0 0 1px rgba(0, 0, 0, 0.10), 0 1px 4px rgba(0, 0, 0, 0.12)
  toast: 0 1px 1px rgba(0, 0, 0, 0.08), 0 4px 12px rgba(0, 0, 0, 0.12)
  card: 0 1px 0 rgba(9, 25, 72, 0.13), 0 1px 1px rgba(18, 55, 105, 0.08)
  book-cover: 0 2px 4px rgba(0, 0, 0, 0.08)
  quote-stage: 0 8px 18px rgba(0, 0, 0, 0.26)
components:
  screen-base:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-primary}"
    padding: "{spacing.screen-margin}"
  card-library:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-loud}"
    rounded: "{rounded.4xl}"
    padding: 12px
    borderColor: "{colors.border-subtle}"
    shadow: "{shadows.card}"
  card-highlight:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text-muted}"
    rounded: "{rounded.4xl}"
    padding: 16px
    borderColor: "{colors.border-subtle}"
  card-empty-state:
    backgroundColor: "{colors.background}"
    rounded: "{rounded.4xl}"
    padding: 24px
  button-primary:
    backgroundColor: "{colors.button-dark}"
    textColor: "{colors.surface}"
    typography: "{typography.label-button}"
    rounded: "{rounded.full}"
    height: 48px
    padding: 0 20px
    shadow: "{shadows.button}"
  button-primary-compact:
    backgroundColor: "{colors.button-dark}"
    textColor: "{colors.surface}"
    typography: "{typography.label-button}"
    rounded: "{rounded.full}"
    height: 36px
    padding: 0 20px
    shadow: "{shadows.button}"
  button-icon-glass:
    backgroundColor: "rgba(255, 255, 255, 0.15)"
    textColor: "{colors.surface}"
    rounded: "{rounded.full}"
    size: 42px
  input-search:
    backgroundColor: "rgba(120, 120, 128, 0.12)"
    textColor: "{colors.text-primary}"
    typography: "{typography.body-regular}"
    rounded: "{rounded.full}"
    padding: 11px 12px
  input-form:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body-regular}"
    rounded: "{rounded.xl}"
    padding: 12px
  textarea-highlight:
    backgroundColor: "{colors.border-subtle}"
    textColor: "{colors.text-primary}"
    typography: "{typography.body-regular}"
    rounded: "{rounded.xl}"
    padding: 12px
  badge-quote-count:
    backgroundColor: "{colors.badge-rose}"
    textColor: "{colors.surface}"
    typography: "{typography.label-badge}"
    rounded: 6px
    padding: 4px 8px
  toast-success:
    backgroundColor: "{colors.surface}"
    textColor: "#2E3038"
    rounded: "{rounded.full}"
    padding: 12px 18px
    shadow: "{shadows.toast}"
---

## Overview
Rememberly feels like a calm reading desk translated into a compact mobile utility. The product is neither playful nor aggressively minimalist; it is warm, light, and intentionally quiet. Most screens use white or near-white surfaces, subdued gray typography, and generous rounded shapes so the experience feels safe and frictionless while handling personal reading notes.

The emotional center of the interface comes from the tension between two modes. The library and editing flows are soft and paper-like, with editorial serif typography used for titles, initials, and quoted text. The capture flow shifts into a darker utility mode, using black staging and bright white controls to focus attention on scanning. The result should feel like a bookish iOS app first and a technical OCR tool second.

## Colors
The palette is built from cool off-whites, muted blue-grays, and a few warm book-cover accents.

- **Backgrounds:** `background`, `background-strong`, and `surface` define almost the entire app. Pure white is used for primary screens and cards, while pale blue-gray backgrounds help empty states, thumbnail wells, and secondary panels feel gently separated without looking heavy.
- **Text:** `text-loud` is reserved for the most important labels and section headers. `text-primary` carries most readable copy. `text-secondary` and `text-subdued` are used for metadata, timestamps, helper text, and less urgent controls.
- **Borders:** Borders are subtle and cool. They act as the main depth system on light screens and should stay soft enough that cards feel cushioned rather than outlined.
- **Accents:** The only saturated colors belong to the book domain: pastel blue, red, yellow, purple, and green cover options; a muted rose quote badge; a warm gold action accent; and a green success state. These accents should feel illustrative and collectible, not brand-loud.
- **Dark mode within the light system:** The camera and OCR selection surfaces are true black. White controls over black create a clear contextual shift into capture mode without changing the overall identity of the app.

## Typography
Typography carries most of the product’s personality. The system depends on pairing a restrained iOS sans-serif with a softer editorial serif.

- **Editorial voice:** Use New York for quoted passages, book initials, and select titles that need literary warmth. It should evoke a printed page rather than a luxury magazine.
- **Utility voice:** Use SF Pro for navigation, labels, metadata, buttons, and form fields. It keeps the app feeling native, direct, and easy to use.
- **Hierarchy:** Large screen titles are decisive but not theatrical. Section titles are medium-large and semibold. Card titles stay compact. Body copy remains readable and understated rather than expressive.
- **Quote treatment:** Quotes should always feel slower and more spacious than surrounding UI copy. Use the serif body styles with generous line height so saved highlights read like excerpts, not feed cards.
- **Metadata:** Timestamps, captions, and author lines should be visibly quieter than titles and quote bodies. The system relies on color de-emphasis more than aggressive size reduction.

## Layout & Spacing
This is a mobile-first layout system with an intentionally consistent rhythm.

- **Outer margins:** Most screens align to a 20px content margin.
- **Rhythm:** The spacing language is driven by 4px, 8px, 12px, 16px, 20px, 24px, 32px, and 40px steps. The most common internal card padding is 12px or 16px.
- **Sectioning:** Home and detail screens separate major blocks with generous vertical gaps. The app should breathe, even when content is sparse.
- **Containment:** Related content is grouped into rounded containers rather than dense lists. Empty states are large, centered, and deliberately padded so they feel welcoming instead of abrupt.
- **Horizontal browsing:** Book collections use short cards in a horizontally scrolling rail. The layout should preserve the sense of browsing physical objects rather than flattening everything into uniform rows.

## Elevation & Depth
Depth is intentionally restrained. The interface is mostly built through tonal contrast, borders, and occasional very soft shadows.

- **Light screens:** Use white cards over white or blue-gray backgrounds, then separate them with subtle strokes and tiny shadows. The cards should feel lifted only slightly, as if resting on clean paper.
- **Media objects:** Book covers and thumbnails can carry a stronger but still compact shadow to suggest a tangible object.
- **Floating UI:** Toasts and primary CTAs use the most visible shadows in the system. These are still soft and rounded, never sharp or glossy.
- **Camera context:** The OCR image stage is the deepest object in the product, with a darker, wider shadow that helps the preview sit above the black background.

## Shapes
The shape language is soft, rounded, and reassuring.

- **Primary cards:** Large containers often use 24px radii.
- **Secondary cards and fields:** Inputs and utility containers sit around 16px to 18px radii.
- **Book media:** Covers use smaller radii, usually 4px to 10px, so they retain the proportions of real books.
- **Buttons:** Primary buttons are capsule-shaped and should feel friendly, thumb-ready, and unmistakably tappable.
- **Circles:** Circular treatments are reserved for icon buttons, cover-color swatches, and symbolic empty-state graphics.

## Components
Component styling should preserve the product’s quiet, book-centered identity.

### Buttons
Primary actions use a dark charcoal capsule with white text and a compact soft shadow. They should feel dependable and native, never flashy. Secondary icon-only controls can use translucent or plain treatments, but should remain visually lighter than the main CTA.

### Book Cards
Book cards pair a soft thumbnail well with a white metadata panel. The upper area is a muted light-gray stage where the book cover or monogram slightly overhangs and casts a tiny shadow. This overhang is important: it makes the library feel tactile and object-based.

### Highlight Cards
Highlight cards are simple white rounded rectangles with a thin border, compact title and timestamp row, and a serif quote preview underneath. The quote should dominate the card visually, while the metadata stays quiet.

### Empty States
Empty states are large centered compositions using illustration, generous whitespace, a short headline, a reassuring sentence, and a single dark CTA. They should feel optimistic and patient rather than sparse.

### Inputs
Search inputs use filled capsule treatments similar to native iOS search. Form inputs use soft rounded rectangles with subtle background fill rather than pronounced outlines. Text editors can use a slightly darker fill than single-line fields to suggest an editable canvas.

### Toasts
Success feedback appears as a white floating capsule with a green confirmation icon and soft shadow. The tone is affirming and lightweight, closer to a small status whisper than a system alert.

### Camera and OCR
The capture flow lives in a black environment with bright white controls and large rounded framing. The preview stage, shutter control, and glass-like close button should feel precise, calm, and focused. Even in this dark context, the product should avoid looking rugged or industrial.

## Do's and Don'ts
- Do keep the overall experience light, quiet, and spacious.
- Do use serif typography selectively to signal books, quotes, and literary content.
- Do let book covers and monogram thumbnails provide most of the visual color.
- Do rely on rounded shapes, subtle borders, and soft shadows instead of heavy contrast blocks.
- Don't introduce highly saturated brand colors across the general UI chrome.
- Don't treat quotes like social feed content; they should read as excerpts from a page.
- Don't replace the dark capsule CTA style with bright filled buttons on standard screens.
- Don't make metadata compete with titles or quote text.
