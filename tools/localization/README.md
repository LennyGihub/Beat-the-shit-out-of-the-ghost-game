# Translations (other languages)

Fixed UI text is translated by Roblox itself once these are on in **Creator Hub > the experience > Localization**:
automatic text capture and automatic translation (pick the languages: Spanish, Portuguese, French, German,
Indonesian, Japanese, Korean... the guide notes Asia-Pacific is 29.5% of Roblox's players).

Text built with numbers ("NEXT GHOST IN 12", "+$350 CASH") goes through `Client/Translate`: the numbers become
`{1}`, `{2}`, the pattern is translated, the numbers are put back. A pattern translates only once it is in the
localization table:

1. Studio playtest: play through toasts, the objective line, the jars / potions tutorial, the sellers.
2. `python3 tools/localization/export_patterns.py` -> `patterns.csv` (grows across sessions).
3. Upload `patterns.csv` in the Localization page; automatic translation fills the languages.
