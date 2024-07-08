;------------------------------------------------
;   Web Server + HTML Tester x64: ver. 2.75
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
  path               dq ?
  dir                dq ?
  name               dq ?
ends

LPBASE_PATH         equ dq
BASE_PATH_SIZE      equ 24
;------------------------------------------------
;   * * *  TABLE_PATH  * * *
;------------------------------------------------
struct TABLE_PATH
  path               dq ?
; dir                dq ?
  session            dq ?
  table              dq ?
  index              dq ?
ends

LPTABLE_PATH        equ dq
TABLE_PATH_SIZE     equ 32
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

LPTEST_HEADER       equ dq
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

LPSCALE_HEADER      equ dq
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
  session            dw ?
  group              dw ?
  time               dw ?
  questions          dw ?
  answers            db ?
  count              db ?
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
  index              dq ?
  user               dq ?
ends

LPUSER_BASE         equ dq
USER_BASE_SIZE      equ 24
USER_BASE_COUNT     equ  3
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
  fieldsize          dd ?,?
  scale              dq ?
  index              dq ?
  text               dq ?
  pathsize           dd ?
ends

LPTEST_BASE         equ dq
TEST_BASE_SIZE      equ 64
TEST_BASE_COUNT     equ  8
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
  testname           dq ?
ends

LPINDEX_BASE        equ dq
INDEX_BASE_SIZE     equ 32
INDEX_BASE_COUNT    equ 4
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
  tablesize          dd ?,?
  index              dq ?
  data               dq ?
  testname           dq ?
  table              dq ?
ends

LPSTORE_BASE        equ dq
STORE_BASE_SIZE     equ 88
STORE_BASE_COUNT    equ 11
STORE_HEADER_COUNT  equ 6
STORE_BASE_COUNT    equ 5
;------------------------------------------------
;   * * *  RSITable.TABLE_HEADER.index
;------------------------------------------------
virtual at RSI
  RSITable.session   dw ?
  RSITable.group     dw ?
  RSITable.time      dw ?
  RSITable.questions dw ?
  RSITable.answers   db ?
  RSITable.user      db ?
  RSITable.start     dd ?
  RSITable.close     dd ?
  RSITable.total     dw ?
  RSITable.score     db ?
end virtual
;------------------------------------------------
;   * * *  RDITable.TABLE_HEADER.index
;------------------------------------------------
virtual at RDI
  RDITable.session   dw ?
  RDITable.group     dw ?
  RDITable.time      dw ?
  RDITable.questions dw ?
  RDITable.answers   db ?
  RDITable.user      db ?
  RDITable.start     dd ?
  RDITable.close     dd ?
  RDITable.total     dw ?
  RDITable.score     db ?
end virtual
;------------------------------------------------
;   * * *  RSITest.TEST_HEADER.index
;------------------------------------------------
virtual at RSI
  RSITest.date       dd ?
  RSITest.questions  dw ?
  RSITest.answers    db ?
  RSITest.tests      dw ?
  RSITest.time       dw ?
  RSITest.level      db ?
  RSITest.scale      dw TEST_SCALE_COUNT dup(?)
end virtual
;------------------------------------------------
;   * * *  RDITest.TEST_HEADER.index
;------------------------------------------------
virtual at RDI
  RDITest.date       dd ?
  RDITest.questions  dw ?
  RDITest.answers    db ?
  RDITest.tests      dw ?
  RDITest.time       dw ?
  RDITest.level      db ?
  RDITest.scale      dw TEST_SCALE_COUNT dup(?)
end virtual
;------------------------------------------------
;   * * *   END  * * *
;------------------------------------------------
