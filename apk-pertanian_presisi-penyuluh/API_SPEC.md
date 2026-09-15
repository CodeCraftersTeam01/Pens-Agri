# Data Contract & API Specifications

## Target Endpoint
`POST https://pertanian.pmapowers.com/api/soil/save`
`Content-Type: multipart/form-data`

## Payload Fields
| Field Name | Type | Description |
| :--- | :--- | :--- |
| `latitude` | `double` | Precise GPS latitude coordinate |
| `longitude` | `double` | Precise GPS longitude coordinate |
| `nama_desa` | `string` | Village / field location name |
| `komoditas` | `string` | Selected commodity name (e.g., Padi) |
| `varietas` | `string` | Specific variety (e.g., Inpari 32) |
| `hasil_panen_lalu` | `double` | Previous harvest volume |
| `satuan_panen` | `string` | Unit identifier (`ton` or `sak`) |
| `temp` | `double` | Soil temperature (°C) |
| `moisture` | `double` | Moisture level (%) |
| `conductivity`| `int` | Electrical conductivity (EC) |
| `ph` | `double` | Soil pH level |
| `nitrogen` | `int` | Nitrogen concentration (mg/kg) |
| `phosphorus` | `int` | Phosphorus concentration (mg/kg) |
| `potassium` | `int` | Potassium concentration (mg/kg) |
| `fertility` | `int` | Soil fertility index |
| `foto_daun` | `File` (Binary) | Image file of the crop leaves |
| `foto_pohon` | `File` (Binary) | Image file of the plant/tree structure |
| `foto_tanah` | `File` (Binary) | Image file of the surrounding soil |