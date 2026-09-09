# YOU FIRST

A three-question research page for **The Ken's Case Competition 2026 — The Great Rewiring**, dressed as 1950s–70s Indian textile-mill press advertising.

Everything is in one self-contained `index.html`: the collage, the styles, the script. No build step, no dependencies to install.

## The questions

1. **What do you struggle with on Amazon, AJIO or Myntra?** — open text
2. **If an agent remembered your preferences — body type, budget, delivery dates — how far does that solve it?** — 1–10 gauge
3. **Would you let that agent buy on its own, inside a budget you set?** — Yes / No, with a follow-up when the answer is No

## Publishing

The page is served as-is. On GitHub Pages, enable Pages for the `main` branch at the repository root and it will be live at `https://paarshviv12.github.io/YOU-FIRST/`.

Sharing is handled on the thank-you screen, which offers a **Copy the link** button reading the page's own address — so it stays correct wherever the page is hosted.

## Collecting responses

Two constants near the top of the `<script>` block:

```js
var FORM_ENDPOINT = "";   // a URL that accepts a POST — Formspree, a Google Apps Script web app, your own API
var WA_NUMBER     = "";   // full international form, digits only, e.g. "919876543210"
```

Leave both empty and the form still works: on submit it shows the thank-you screen with a **Copy my answers** button, so nothing is lost. Set `FORM_ENDPOINT` and it POSTs JSON:

| field | type | notes |
|---|---|---|
| `answer_one` | string | Q1, free text |
| `rating_two` | number \| null | 1–10, or `null` if the gauge was never moved |
| `allow_auto` | string | `"Yes"` / `"No"` / `""` |
| `why_not` | string | only when `allow_auto` is `"No"` |
| `age_band` | string | `"18–24"`, `"25–34"`, … |
| `city` | string | free text |
| `consent` | boolean | must be true to submit |
| `submitted` | string | ISO 8601 |
| `page` | string | the URL it was filled in on |

`rating_two` is deliberately nullable: the gauge starts unset rather than at 5, so an untouched slider never records a phantom rating.

## Consent

The competition publishes quotes with an age band and city and no name. The form collects that consent explicitly before submission, so responses arrive already cleared for use.

## Credits

- Collage: Indian textile-mill press advertising, c. 1950–1975
- Type: Anton, Bodoni Moda, Libre Baskerville, Karla (Google Fonts)
- Thank-you GIF: [Hamtaro Dancing](https://tenor.com/view/hamtaro-dancing-kawaii-funny-gif-20305453) via Tenor
