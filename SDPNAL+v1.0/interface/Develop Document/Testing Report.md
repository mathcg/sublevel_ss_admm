# Testing Report 

## Operator Overload Test

### plus / +


|            | var\_free | var\_nn | var\_sdp | var\_symm | expression | Constant |
| ---------- | --------- | ------- | -------- | --------- | ---------- | -------- |
| var\_free  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_nn    | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_sdp   | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_symm  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| expression | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| Constant   | ✓         | ✓       | ✓        | ✓         | ✓          |          |


### minus / - 

|            | var\_free | var\_nn | var\_sdp | var\_symm | expression | Constant |
| ---------- | --------- | ------- | -------- | --------- | ---------- | -------- |
| var\_free  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_nn    | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_sdp   | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_symm  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| expression | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| Constant   | ✓         | ✓       | ✓        | ✓         | ✓          |          |

### mtimes / *

|        | var\_free | var\_nn | var\_sdp     | var\_symm    | expression        |
| ------ | --------- | ------- | ------------ | ------------ | ----------------- |
| scalar | ✓         | ✓       | ✓            | ✓            | ✓                 |
| matrix | ✓         | ✓       | not possible | not possible | ✓                 |
| cell   | ✓         | ✓       | ✓            | ✓            | not supported yet |


### eq / == 

|            | var\_free | var\_nn | var\_sdp | var\_symm | expression | Constant |
| ---------- | --------- | ------- | -------- | --------- | ---------- | -------- |
| var\_free  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_nn    | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_sdp   | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_symm  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| expression | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| Constant   | ✓         | ✓       | ✓        | ✓         | ✓          |          |

### ge / >= 

|            | var\_free | var\_nn | var\_sdp | var\_symm | expression | Constant |
| ---------- | --------- | ------- | -------- | --------- | ---------- | -------- |
| var\_free  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_nn    | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_sdp   | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_symm  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| expression | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| Constant   | ✓         | ✓       | ✓        | ✓         | ✓          |          |

### le / <= 

|            | var\_free | var\_nn | var\_sdp | var\_symm | expression | Constant |
| ---------- | --------- | ------- | -------- | --------- | ---------- | -------- |
| var\_free  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_nn    | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_sdp   | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| var\_symm  | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| expression | ✓         | ✓       | ✓        | ✓         | ✓          | ✓        |
| Constant   | ✓         | ✓       | ✓        | ✓         | ✓          |          |


### other operator

|           | var\_free | var\_nn | var\_sdp | var\_symm | expression      |
| --------- | --------- | ------- | -------- | --------- | --------------- |
| times/ .* | ✓         | ✓       | ✓        | ✓         | Not support yet |
| uplus/ +  | ✓         | ✓       | ✓        | ✓         | ✓               |
| uminus/ - | ✓         | ✓       | ✓        | ✓         | ✓               |



## Predefined Maps Test

|            | var\_free     | var\_nn       | var\_sdp      | var\_symm     | expression        |
| ---------- | ------------- | ------------- | ------------- | ------------- | ----------------- |
| get\_value | ✓             | ✓             | ✓             | ✓             | Not supported     |
| inprod     | ✓             | ✓             | ✓             | ✓             | Not supported yet |
| l1\_norm   | ✓             | ✓             | ✓             | ✓             | ✓                 |
| map\_diag  | ✓             | ✓             | ✓             | ✓             | Not supported yet |
| map\_vec   | ✓             | ✓             | Not supported | Not supported | Not supported     |
| map\_svec  | Not supported | Not supported | ✓             | ✓             | Not supported     |
| sum        | ✓             | ✓             | ✓             | ✓             | Not supported yet |
| trace      | ✓             | ✓             | ✓             | ✓             | Not supported     |

## Functions in sdp\_model

### add\_affine\_constraint

| lower\_bound | upper\_bound | twodirect\_bound | affine\_ expression | chain |
| ------------ | ------------ | ---------------- | ------------------- | ----- |
| ✓            | ✓            | ✓                | ✓                   | ✓     |

### add\_psd\_constraint

| lower\_bound | upper\_bound | twodirect\_bound | affine\_expression | chain |
| ------------ | ------------ | ---------------- | ------------------ | ----- |
| ✓            | ✓            | ✓                | ✓                  | ✓     |

### Others

| add\_variable | minimize | maximize | setparameter |
| ------------- | -------- | -------- | ------------ |
| ✓             | ✓        | ✓        | ✓            |