# popes
Dataset of all official popes from Peter to Francis, scraped from the Wikipedia article ["List of popes"](https://en.wikipedia.org/wiki/List_of_popes).

## Variables
- `number`: Pontiff number
- `name_full`: Pope name including regnal suffix in roman numerals
- `name`: Pope name without suffix
- `suffix`: Regnal suffix in integer format
- `canonization`: Stage in canonization process, if applicable
- `birth`: Date of birth
- `start`: Date of accession to papacy
- `end`: Date of end of papacy
- `age_start`: Age at start of papacy, in full years 
- `age_end`: Age at end of papacy, in full years
- `tenure`: Length of papacy, in fractional years

## Notes
- All antipopes were excluded.
- Where only birth years are given, the birth date is assumed to be 30 June.
- Where only years are given for the pope's tenure, it is assumed that tenure started on 1 January and ended on 31 December.
- Where multiple or a range of years are given due to historical uncertainty, the earliest year is used.  
