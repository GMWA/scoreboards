# Bundled fonts

The app uses these fonts through the `google_fonts` package with runtime
fetching turned off (`lib/main.dart`), so every family and weight it uses
must be here. `test/bundled_fonts_test.dart` fails when one is missing.

To add one, download the static `.ttf` that `google_fonts` would fetch:
its file hash is in the package source
(`lib/src/google_fonts_parts/part_<letter>.g.dart`, under the family's
`GoogleFontsVariant(fontWeight: ..., fontStyle: ...)`), and the file is
`https://fonts.gstatic.com/s/a/<hash>.ttf`. Save it as
`<Family>-<Variant>.ttf`, e.g. `HankenGrotesk-SemiBold.ttf`.

The fonts are under the SIL Open Font License (`*-OFL.txt`), shown in the
app's licenses page.
