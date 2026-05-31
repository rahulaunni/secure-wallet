# Performance Runtime Report

Scope: instrumented runtime measurement of `HomeScreen` on a Chrome runtime harness with 12 seeded cards and one measured vertical scroll gesture.

## Environment Notes

- Target: `flutter run -d chrome -t lib/perf_runtime_main.dart`
- Measurement source: temporary runtime probes added to `HomeScreen`, `BankCard`, `SecureRevealWrapper`, `CardVisualAssetLayer`, and `BankLogo`
- Runtime caveat: the Chrome run also logged `unhandled element <filter/>; Picture key: Svg loader`
- Runtime caveat: an earlier harness run produced repeated `google_fonts` font-loading exceptions on web; the metrics below come from the successful payload emitted before shutdown, so treat absolute frame timings as directional rather than lab-grade

## Rebuild Counts

- HomeScreen rebuild count: `2`
- Total instrumented widget rebuilds: `98`
- Total BankCard rebuilds: `24`
- Average BankCard build duration: `0.445 ms`

## Frame Timing

- Average frame time: `104.60 ms`
- Worst frame time: `260.90 ms`
- UI thread time: `103.24 ms` avg, `257.80 ms` worst
- Raster time: `1.36 ms` avg, `3.10 ms` worst
- Frame count: `5`

## Card Presence

- Cards visible: `6` initially, `8` after scroll
- Cards mounted: `12` current, `12` peak
- Repaint events: `76`

## Slowest Widgets

- `HomeScreen`: `10.200 ms` avg, `13.700 ms` max across `2` samples
- `PremiumTexturePainter paint`: `3.870 ms` avg, `6.899 ms` max across `24` samples
- `CardVisualAssetLayer paint`: `1.074 ms` avg, `8.700 ms` max across `52` samples
- `BankCard`: `0.445 ms` avg, `7.500 ms` max across `24` samples
- `CardVisualAssetLayer`: `0.204 ms` avg, `1.500 ms` max across `24` samples
- `BankLogo`: `0.050 ms` avg, `0.300 ms` max across `24` samples
- `SecureRevealWrapper`: `0.016 ms` avg, `0.100 ms` max across `24` samples
- `BankLogo svg resolve`: `0.004 ms` avg, `0.100 ms` max across `24` samples

## BankCard Rebuilds

- `hdfc|||4111111111111000|||||||||12/30|User 0`: `2` builds, `3.849 ms` avg, `7.500 ms` max
- `axis|||4111111111111001|||||||||12/31|User 1`: `2` builds, `0.150 ms` avg, `0.199 ms` max
- `icici|||4111111111111002|||||||||12/32|User 2`: `2` builds, `0.150 ms` avg, `0.200 ms` max
- `kotak|||4111111111111003|||||||||12/33|User 3`: `2` builds, `0.249 ms` avg, `0.399 ms` max
- `idbi|||4111111111111004|||||||||12/34|User 4`: `2` builds, `0.150 ms` avg, `0.201 ms` max
- `federal|||4111111111111005|||||||||12/35|User 5`: `2` builds, `0.100 ms` avg, `0.200 ms` max
- `indusind|||4111111111111006|||||||||12/36|User 6`: `2` builds, `0.099 ms` avg, `0.199 ms` max
- `rbl|||4111111111111007|||||||||12/37|User 7`: `2` builds, `0.050 ms` avg, `0.100 ms` max

## Scroll Gesture Metrics

- Gesture `1`: `49` instrumented rebuilds, `1` HomeScreen rebuilds, `12` BankCard rebuilds, `1700.000 ms` duration, `3` update notifications

## Time Breakdown From Probes

- `CardVisualAssetLayer` build time: `0.204 ms` avg, `1.500 ms` max, `24` samples
- `CardVisualAssetLayer` paint time: `1.074 ms` avg, `8.700 ms` max, `52` samples
- `PremiumTexturePainter` paint time: `3.870 ms` avg, `6.899 ms` max, `24` samples
- `BankLogo` SVG resolve time: `0.004 ms` avg, `0.100 ms` max, `24` samples
- `SecureRevealWrapper` build time: `0.016 ms` avg, `0.100 ms` max, `24` samples

## Suspected Bottlenecks

- The measured scroll gesture triggered `49` instrumented rebuilds, which points to broad rebuild propagation during scrolling.
- BankCard rebuilt `12` times during one scroll gesture, which is high for a list that should mostly reuse existing rows.
- Mounted card count stays well above visible card count, which supports the earlier finding that off-screen cards remain in the widget tree.
- CardVisualAssetLayer paint time is elevated, which matches the layered SVG texture path called out in the static audit.
- The data is much more UI-thread bound than raster bound in this run, so the primary stall is rebuild/layout work rather than raw GPU fill.
