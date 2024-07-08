;------------------------------------------------
;   Web Server + HTML Tester x32: ver. 2.75
;   MAIN: Structures
;   (c) Kyiv, Ruslan FoXx
;   01 July 2024
;------------------------------------------------
TABLE_STATUS_CREATE equ   0
TABLE_STATUS_DELETE equ   1
TABLE_STATUS_ARHIVE equ 128

BASE_HEAD_SIZE      equ   7
GROUP_HEAD_SIZE     equ   5
;------------------------------------------------
;   * * *  BASE_PATH  * * *
;------------------------------------------------
struct BASE_PATH
  path               dd ?
  dir                dd ?
  name               dd ?
ends

LPBASE_PATH         equ dd
BASE_PATH_SIZE      equ 12
;------------------------------------------------
;   * * *  TABLE_PATH  * * *
;------------------------------------------------
struct TABLE_PATH
  path               dd ?
; dir                dd ?
  session            dd ?
  table              dd ?
  index              dd ?
ends

LPTABLE_PATH        equ dd
TABLE_PATH_SIZE     equ 16
;------------------------------------------------
;   * * *  TEST_HEADER  * * *
;------------------------------------------------
TEST_SCALE_COUNT    equ 12

struct TEST_HEADER
  date               dd ?
  questions          dw ?
  answers            db ?
  tests              dw ?
  time               dw ?
  level              db ?
  scale              dw TEST_SCALE_COUNT dup(?)
ends

LPTEST_HEADER       equ dd
TEST_HEADER_SIZE    equ 36  ;   12 + 24
TEST_HEADER_COUNT   equ  9
;------------------------------------------------
;   * * *  SCALE_HEADER  * * *
;------------------------------------------------
;TEST_SCALE_COUNT   equ 12

struct SCALE_HEADER
  questions          dw ?
  time               dw ?
  level              db ?
  scale              dw TEST_SCALE_COUNT dup(?)
ends

LPSCALE_HEADER      equ dd
SCALE_HEADER_SIZE   equ 29
;------------------------------------------------
;   * * *  INDEX_HEADER  * * *
;------------------------------------------------
struct INDEX_HEADER
; fields             dw ?    ;    header
; session            dw ?

  group              dw ?
  date               dd ?
  count              db ?
  attribute          db ?
  index              dw ?
ends

LPINDEX_HEADER      equ dq
INDEX_HEADER_SIZE   equ 10
INDEX_HEADER_COUNT  equ  3
INDEX_NAME_SIZE     equ 32
;------------------------------------------------
;   * * *  TABLE_HEADER  * * *
;------------------------------------------------
struct TABLE_HEADER
  session            dw ?
  group              dw ?
  time               dw ?
  questions          dw ?
  answers            db ?

  user               db ?    ;    [00-09] userid
  start              dd ?    ;    [0A-14] deblock
  close              dd ?
  total              dw ?
  score              db ?
ends

LPTABLE_HEADER      equ dq
TABLE_HEADER_SIZE   equ 21
TABLE_HEADER_DATA   equ 12
;------------------------------------------------
;   * * *  STORE_HEADER  * * *
;------------------------------------------------
struct STORE_HEADER
  count              db ?
  session            dw ?
  group              dw ?
  time               dw ?
  questions          dw ?
  answers            db ?
ends

LPSTORE_HEADER      equ dq
STORE_HEADER_SIZE   equ 10
;------------------------------------------------
;   * * *  USER_HEADER  * * *
;------------------------------------------------
struct USER_HEADER
  date               dd ?
  count              db ?
; index              dd ?
ends

LPUSER_HEADER       equ dd
USER_HEADER_SIZE    equ  5
;------------------------------------------------
;   * * *  USER_BASE  * * *
;------------------------------------------------
struct USER_BASE
  date               dd ?
  count              dd ?
  index              dd ?
  user               dd ?
ends

LPUSER_BASE         equ dd
USER_BASE_SIZE      equ 16
USER_BASE_COUNT     equ  4
;------------------------------------------------
;   * * *  TEST_BASE  * * *
;------------------------------------------------
struct TEST_BASE
  date               dd ?
  questions          dd ?
  answers            dd ?
  tests              dd ?
  time               dd ?
  level              dd ?
  fieldsize          dd ?
  scale              dd ?
  index              dd ?
  text               dd ?
  pathsize           dd ?
ends

LPTEST_BASE         equ dd
TEST_BASE_SIZE      equ 44
TEST_BASE_COUNT     equ 11
;------------------------------------------------
;   * * *  INDEX_BASE  * * *
;------------------------------------------------
struct INDEX_BASE
  fields             dd ?
  session            dd ?
  group              dd ?
  date               dd ?
  count              dd ?
  attribute          dd ?
  testname           dd ?
ends

LPINDEX_BASE        equ dd
INDEX_BASE_SIZE     equ 28
INDEX_BASE_COUNT    equ 7
;------------------------------------------------
;   * * *  TABLE_BASE  * * *
;------------------------------------------------
struct TABLE_BASE
  count              dd ?
  session            dd ?
  group              dd ?
  time               dd ?
  tests              dd ?
  items              dd ?

  user               dd ?
  start              dd ?
  close              dd ?
  total              dd ?
  score              dd ?

  fieldsize          dd ?
  tablesize          dd ?
  index              dd ?
  data               dd ?
  testname           dd ?
  table              dd ?
ends

LPSTORE_BASE        equ dd
STORE_BASE_SIZE     equ 68
STORE_BASE_COUNT    equ 17
STORE_HEADER_COUNT  equ 6
STORE_BASE_DATA     equ 5
;------------------------------------------------
;   * * *  ESITable.TABLE_HEADER.index
;------------------------------------------------
virtual at ESI
  ESITable.session   dw ?
  ESITable.group     dw ?
  ESITable.time      dw ?
  ESITable.questions dw ?
  ESITable.answers   db ?
  ESITable.user      db ?
  ESITable.start     dd ?
  ESITable.close     dd ?
  ESITable.total     dw ?
  ESITable.score     db ?
end virtual
;------------------------------------------------
;   * * *  EDITable.TABLE_HEADER.index
;------------------------------------------------
virtual at EDI
  EDITable.session   dw ?
  EDITable.group     dw ?
  EDITable.time      dw ?
  EDITable.questions dw ?
  EDITable.answers   db ?
  EDITable.user      db ?
  EDITable.start     dd ?
  EDITable.close     dd ?
  EDITable.total     dw ?
  EDITable.score     db ?
end virtual
;------------------------------------------------
;   * * *  ESITest.TEST_HEADER.index
;------------------------------------------------
virtual at ESI
  ESITest.date       dd ?
  ESITest.questions  dw ?
  ESITest.answers    db ?
  ESITest.tests      dw ?
  ESITest.time       dw ?
  ESITest.level      db ?
  ESITest.scale      dw TEST_SCALE_COUNT dup(?)
end virtual
;------------------------------------------------
;   * * *  EDITest.TEST_HEADER.index
;------------------------------------------------
virtual at EDI
  EDITest.date       dd ?
  EDITest.questions  dw ?
  EDITest.answers    db ?
  EDITest.tests      dw ?
  EDITest.time       dw ?
  EDITest.level      db ?
  EDITest.scale      dw TEST_SCALE_COUNT dup(?)
end virtual
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
