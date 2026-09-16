# Product Requirement Document (PRD) - Smart Agri Soil Monitoring Mobile App

## 1. Project Overview
Refactor the monolithic Flutter codebase into a modular, clean, and production-ready architecture. The app interfaces with a physical 8-in-1 soil probe via USB Serial (CH340), captures contextual field observations, compares real-time telemetry against crop-specific baselines, and transmits comprehensive field datasets to the cloud backend.

---

## 2. System Architecture & Modular Directory Layout
The codebase must be modularized strictly under `lib/`:

```text
lib/
├── main.dart                             # App entry point, theme setup, routing
├── core/
│   ├── constants/
│   │   └── colors.dart                   # Stitch design palette & typography tokens
│   └── services/
│       ├── usb_serial_service.dart       # MethodChannel & Modbus communication
│       ├── location_service.dart         # Geolocator integration
│       └── api_service.dart              # Multipart HTTP synchronization
├── models/
│   ├── commodity_model.dart              # Commodity, variety, & nutrient threshold bounds
│   └── soil_sample_model.dart            # Telemetry data, media paths, & harvest inputs
└── views/
    ├── home/
    │   └── commodity_selection_page.dart # Grid catalog of commodities & varieties
    ├── checkup/
    │   └── soil_probe_capture_page.dart  # Sensor cards, GPS, 3-image picker, yield input
    └── result/
        └── analysis_result_page.dart     # Nutrient justification & soil remediation cards
3. Screen Specifications & Flows
Screen 1: Commodity Selection (commodity_selection_page.dart)
Commodity Catalog: Dynamic grid view displaying agricultural commodities (e.g., Padi Inpari 32, Cabai Rawit, Jagung, Singkong, Tembakau, Bawang Merah).

Variety Baseline Binding: Selecting a commodity and variety locks the reference threshold values (N, P, K, pH, moisture, conductivity) used for soil justification.

Navigation: Primary action button directly routes the user to Screen 2.

Screen 2: Soil Probe & Data Capture (soil_probe_capture_page.dart)
Sensor Telemetry Panel: Real-time data visualization cards for 8 soil parameters:

Moisture (%)

Temperature (°C)

Electrical Conductivity / EC (µS/cm)

pH Level

Nitrogen / N (mg/kg)

Phosphorus / P (mg/kg)

Potassium / K (mg/kg)

Fertility Index (mg/kg)

Hardware Communication Controls:

Connect / Disconnect button interfacing with the CH340 USB Serial driver.

"Baca Data Sensor" action button executing the Modbus query cycle.

Geotagging Service: Automatic retrieval of precise GPS coordinates (Latitude and Longitude) using the device location provider.

Yield History Input: Numerical input field with a unit switch toggle (Ton / Sak) to record previous harvest volume.

Multimedia Capture Module: Three dedicated camera capture cards requiring separate images:

Leaf image (foto_daun)

Plant/tree structure image (foto_pohon)

Soil structure image (foto_tanah)

Form Validation & Action: Submitting triggers a validation check across telemetry, media, and location before navigating to Screen 3.

Screen 3: Justification & Soil Remediation (analysis_result_page.dart)
Nutrient Analysis Engine: Evaluates active sensor readings against baseline bounds of the selected commodity variety.

Status Indicators: Explicit status tags per parameter (Defisit / Low, Normal / Optimal, Berlebih / High).

Remediation Plan Cards: Actionable recommendations detailing:

Chemical fertilizer adjustments based on specific N-P-K and pH variances.

Physical soil condition improvements (aeration, drainage, organic matter).

Cloud Synchronization: Final action button sends the entire payload via multipart/form-data to https://pertanian.pmapowers.com/api/soil/save.