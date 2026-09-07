# Kindle Colorsoft CoverFit

Experimental adaptation of the classic ScreenSavers Hack for a jailbroken Kindle Colorsoft on firmware 5.19.5.

## Goal

Use the cover of the most recently opened book—including Kindle Store books—and render it as a full-screen lock-screen image. CoverFit uses aspect-fill: proportional scaling followed by a centered crop. It never stretches a cover.

## Current status

**Research/diagnostic preview. Do not install the legacy Update_linkss packages on a Colorsoft.** They were built for older Kindle generations and native ABIs.

The Colorsoft implementation is split into three parts:

1. discover the current book and Amazon's local cover-cache entry;
2. render a 1264 × 1680 color image with aspect-fill;
3. hand the result to a firmware-5.19.5-compatible lock-screen hook.

The safe renderer is implemented in colorsoft/coverfit.sh. The firmware hook is intentionally not enabled until its event and display interfaces are verified on a real 5.19.5 Colorsoft. This prevents root-filesystem or Amazon-service changes based on guesses.

## Why the old implementation cannot simply be installed

The upstream cover-extract reads the last-opened entry from /var/local/cc.db, extracts MOBI/KF8 covers, then performs ImageMagick aspect-fill cropping. That crop behavior is preserved here.

Modern Kindle Store downloads are commonly KFX, and Colorsoft is a hard-float color device. The old extractor explicitly rejects KFX, while its bundled native tools are not a safe match. The modern design therefore reuses Amazon's already-rendered local cover cache instead of decrypting or rewriting purchased books.

## Safety

No automatic installer or firmware hook is shipped yet. Nothing here modifies books, the content database, firmware, or system services. The old packages remain only as upstream source history.
