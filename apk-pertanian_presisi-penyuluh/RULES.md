# Agent Execution Rules & Codebase Invariants

## CRITICAL DIRECTIVE: ZERO REGRESSION ON HARDWARE LOGIC
The physical soil probe relies on a specific USB Serial communication pipeline. The agent MUST NOT alter, replace with mocks, or rewrite the underlying Modbus communication protocol.

### 1. Inviolable Logic
- **MethodChannel Identifier:** Must remain exactly `'id.ac.pens/usb_serial'`.
- **Platform Invocations:**
  - `_platform.invokeMethod('connectCH340')`
  - `_platform.invokeMethod('disconnectCH340')`
  - `_platform.invokeMethod('sendModbusQuery')`
- **Modbus Request Frame:** Must strictly query `01 03 00 00 00 08 44 0C`.
- **Byte Decoding Logic:**
  - Moisture: `((b[3] << 8) | b[4]) / 10.0`
  - Temperature: `((b[5] << 8) | b[6]) / 10.0`
  - EC: `(b[7] << 8) | b[8]`
  - pH: `((b[9] << 8) | b[10]) / 10.0`
  - Nitrogen (N): `(b[11] << 8) | b[12]`
  - Phosphorus (P): `(b[13] << 8) | b[14]`
  - Potassium (K): `(b[15] << 8) | b[16]`
  - Fertility: `(b[17] << 8) | b[18]`

### 2. Refactoring Boundaries
- Isolate the above hardware logic into `lib/core/services/usb_serial_service.dart`. Do not embed raw platform calls directly inside UI widgets.
- Never strip out existing permissions or Android-level native configurations.
- Ensure all new dependencies (such as `image_picker`) added to `pubspec.yaml` compile cleanly without null-safety violations or missing platform manifest entries (`AndroidManifest.xml`).

### 3. Design Enforcement
- Adhere to the visual structure provided by Stitch (green agricultural design tokens, clean cards, modern typography, elevation, and rounded borders).
- Eliminate outdated single-file terminal logs and dark wireframe blocks in favor of high-fidelity dashboard cards.