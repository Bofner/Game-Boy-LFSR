;Header byte follows this format:
;7:     1 = TILE, 0 = MAP
;6:     1 = Uncompressed
;5 & 4: 00 = SCRN, 01 = TALL
;       10 = WIDE, 11 = FULL
;0-3: Unused but set to 1
.DB %11001111

;Size of uncompressed tile data:
.DW $0010
;Raw tile data 
.DB $00 $10 $02 $14 $0C $72 $7E $72 $18 $0F $33 $17 $60 $24 $44 $44 