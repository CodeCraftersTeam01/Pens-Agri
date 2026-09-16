package id.ac.pens.pertanian_presisi.petani
 
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import com.hoho.android.usbserial.driver.UsbSerialProber
import com.hoho.android.usbserial.driver.UsbSerialPort
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "id.ac.pens/usb_serial"
    private val ACTION_USB_PERMISSION = "id.ac.pens.pertanian_presisi.petani.USB_PERMISSION"
    private var sPort: UsbSerialPort? = null
    private var usbReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "connectCH340" -> {
                        val manager = getSystemService(Context.USB_SERVICE) as? UsbManager
                        if (manager == null) {
                            result.error("NO_USB_SERVICE", "Layanan USB Manager tidak tersedia pada sistem.", null)
                            return@setMethodCallHandler
                        }

                        val availableDrivers = try {
                            UsbSerialProber.getDefaultProber().findAllDrivers(manager)
                        } catch (e: Exception) {
                            emptyList()
                        }
                        
                        if (availableDrivers.isEmpty()) {
                            result.error("NO_DEVICE", "Tidak ada perangkat USB Serial terdeteksi. Cek OTG & Kabel!", null)
                            return@setMethodCallHandler
                        }

                        val driver = availableDrivers[0]
                        val device = driver.device

                        if (!manager.hasPermission(device)) {
                            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                            } else {
                                PendingIntent.FLAG_UPDATE_CURRENT
                            }
                            val permissionIntent = PendingIntent.getBroadcast(this, 0, Intent(ACTION_USB_PERMISSION), flags)
                            
                            // Unregister previous receiver if existing
                            usbReceiver?.let {
                                try { unregisterReceiver(it) } catch (_: Exception) {}
                            }

                            val filter = IntentFilter(ACTION_USB_PERMISSION)
                            val receiver = object : BroadcastReceiver() {
                                override fun onReceive(context: Context?, intent: Intent?) {
                                    if (ACTION_USB_PERMISSION == intent?.action) {
                                        synchronized(this) {
                                            try {
                                                context?.unregisterReceiver(this)
                                            } catch (_: Exception) {}
                                            usbReceiver = null

                                            val granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)
                                            if (granted) {
                                                bukaPortKomunikasi(manager, driver, result)
                                            } else {
                                                result.error("PERMISSION_DENIED", "Izin USB ditolak oleh user.", null)
                                            }
                                        }
                                    }
                                }
                            }
                            usbReceiver = receiver

                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
                            } else {
                                registerReceiver(receiver, filter)
                            }

                            manager.requestPermission(device, permissionIntent)
                            return@setMethodCallHandler
                        }

                        bukaPortKomunikasi(manager, driver, result)
                    }
                    
                    "sendModbusQuery" -> {
                        if (sPort == null) {
                            result.error("NOT_CONNECTED", "Port belum terbuka.", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val query = byteArrayOf(0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C)
                            sPort!!.write(query, 2000)

                            val buffer = ByteArray(32)
                            val numBytesRead = sPort!!.read(buffer, 2000)
                            
                            if (numBytesRead >= 21) {
                                val dataList = ArrayList<Int>()
                                for (i in 0 until numBytesRead) {
                                    dataList.add(buffer[i].toInt() and 0xFF)
                                }
                                result.success(dataList)
                            } else {
                                result.error("TIMEOUT", "Sensor tidak merespon (Cek kabel A B / catu daya sensor).", null)
                            }
                        } catch (e: Exception) {
                            result.error("ERR_WRITE", e.message, null)
                        }
                    }

                    "disconnectCH340" -> {
                        try {
                            sPort?.close()
                            sPort = null
                            result.success("Koneksi USB Diputus")
                        } catch (e: Exception) {
                            result.error("ERR_CLOSE", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("UNEXPECTED_ERROR", e.message, null)
            }
        }
    }

    override fun onDestroy() {
        usbReceiver?.let {
            try { unregisterReceiver(it) } catch (_: Exception) {}
            usbReceiver = null
        }
        try {
            sPort?.close()
            sPort = null
        } catch (_: Exception) {}
        super.onDestroy()
    }

    private fun bukaPortKomunikasi(manager: UsbManager, driver: com.hoho.android.usbserial.driver.UsbSerialDriver, result: MethodChannel.Result) {
        try {
            val connection = manager.openDevice(driver.device)
            if (connection == null) {
                result.error("CONN_FAIL", "Sistem Android menolak membuka device. Re-colok OTG.", null)
                return
            }

            sPort = driver.ports[0]
            sPort!!.open(connection)
            sPort!!.setParameters(9600, 8, UsbSerialPort.STOPBITS_1, UsbSerialPort.PARITY_NONE)
            result.success("USB Serial Terhubung (@9600 Baud)")
        } catch (e: Exception) {
            result.error("ERR_IO", e.message, null)
        }
    }
}
