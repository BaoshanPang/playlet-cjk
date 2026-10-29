# playlet-cjk

Make [Playlet](https://github.com/iBicha/playlet) — the ad-free YouTube client
for Roku — render **Chinese** (and other CJK) video titles correctly.

## The problem

On Roku TVs whose system fonts lack CJK glyphs, Playlet shows Chinese video
titles as empty boxes (`□□□`). Playlet uses Roku system fonts and ships no font
of its own, so it inherits whatever the TV has. The official YouTube app does
not have this problem because it bundles its own font.

## The fix

`patch_cjk.py` builds a patched Playlet package:

1. downloads a Playlet release (channel + component library),
2. downloads [Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC)
   (OFL) and instances Regular/Bold static TTFs,
3. rewires every system-font reference in the library — XML `font=`/`focusedFont=`
   attributes, `<Font uri="font:...SystemFontFile">` nodes, `fontUri=` attributes
   and the two BrightScript sites that assign fonts in code — to the bundled
   fonts,
4. embeds the patched library into the channel and makes the channel load it
   first, so the result is fully self-contained (no server needed).

```bash
pip install fonttools
python3 patch_cjk.py                 # latest release -> ./playlet-cjk.zip
python3 patch_cjk.py --release v0.48.10
```

Then sideload (Roku dev mode required):

```bash
curl --digest -u rokudev:PASSWORD \
     -F "mysubmit=Install" \
     -F "archive=@playlet-cjk.zip;type=application/octet-stream" \
     http://ROKU_IP/plugin_install
```

### Small channel + your own HTTP server (optional)

`--remote-lib http://host:port/playlet-lib.zip` builds an additional ~1 MB
`playlet-cjk-channel.zip` that loads the patched library from your own HTTP
server at launch instead of embedding it. Useful if the target device rejects
large sideloads; the library falls back to GitHub if your server is down.

## Tested on

- TCL 32S327 (Roku TV, Roku OS 15.3.4), Playlet v0.48.10
- Chinese titles render correctly after the patch (previously boxes)

## Notes and limitations

- A sideloaded dev channel does not auto-update. Re-run the script (and
  re-sideload) to refresh; it always starts from a fresh official release zip.
- Roku allows only one sideloaded app at a time; installing another dev app
  replaces it. Playlet from the official Roku channel store keeps working.
- If the installer reports `Install timeout. Results unknown.` and the dev
  channel never appears, the device's install pipeline is wedged — a full
  system restart (Settings → System → Power → System restart) cleared it for
  us; subsequent installs then succeed.
- Some labels still use the system default font (e.g. text typed into the
  on-screen keyboard). Typing Chinese works best via Playlet's own "Remote"
  tab from a phone browser.
- Playlet does not support subtitles/captions at all (any language) — this
  tool does not change that.

## Credits

- [iBicha/playlet](https://github.com/iBicha/playlet) (AGPL-3.0) — the app being patched
- [Noto Sans SC](https://fonts.google.com/noto/specimen/Noto+Sans+SC) — SIL Open Font License
- [fonttools](https://github.com/fonttools/fonttools) — variable-font instancing

## License

MIT — see [LICENSE](LICENSE).
