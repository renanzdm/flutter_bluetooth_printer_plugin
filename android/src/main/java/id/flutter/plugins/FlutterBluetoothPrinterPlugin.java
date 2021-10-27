package id.flutter.plugins;

import static android.os.Build.VERSION.SDK_INT;

import android.Manifest;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.broadcastreceiver.BroadcastReceiverAware;
import io.flutter.embedding.engine.plugins.broadcastreceiver.BroadcastReceiverPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterBluetoothPrinterPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler, BroadcastReceiverAware {
    private MethodChannel channel;
    private Activity activity;

    private BluetoothAdapter bluetoothAdapter;
    private BluetoothSocket bluetoothSocket;
    private OutputStream writeStream;
    private IntentFilter filter;
    private BluetoothDevice connectedDevice;
    private Map<String, BluetoothDevice> discoveredDevices = new HashMap<>();
    final int REQUEST_CODE = 111111;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "id.flutter.plugins/bluetooth_printer");
        channel.setMethodCallHandler(this);
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        flutterPluginBinding.getApplicationContext().registerReceiver(receiver, filter);


    }

    private final BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                final Map<String, Object> map = deviceToMap(device);
                channel.invokeMethod("onDiscovered", map);
                discoveredDevices.put(device.getAddress(), device);
            }
        }
    };

    private Map<String, Object> deviceToMap(BluetoothDevice device) {
        final HashMap<String, Object> map = new HashMap<>();
        map.put("name", device.getName());
        map.put("address", device.getAddress());
        map.put("type", device.getType());

        if (connectedDevice == null) {
            map.put("is_connected", false);
        } else {
            map.put("is_connected", device.getAddress().equals(connectedDevice.getAddress()));
        }
        return map;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        final String method = call.method;
        switch (method) {
            case "isEnabled":
                isEnabled(result);
                break;

            case "startScan":
                if (!bluetoothAdapter.isDiscovering()) {
                    discoveredDevices.clear();
                    bluetoothAdapter.startDiscovery();
                }
                result.success(true);
                break;

            case "stopScan":
                if (bluetoothAdapter.isDiscovering()) {
                    bluetoothAdapter.cancelDiscovery();
                }
                result.success(true);
                break;

            case "isConnected":
                result.success(connectedDevice != null);
                break;

            case "connectedDevice":
                if (connectedDevice != null) {
                    result.success(deviceToMap(connectedDevice));
                    return;
                }

                result.success(null);
                break;

            case "connect":
                AsyncTask.execute(() -> {
                    try {
                        String address = call.argument("address");
                        final BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
                        UUID uuid = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb");
                        bluetoothSocket = device.createRfcommSocketToServiceRecord(uuid);
                        bluetoothSocket.connect();
                        connectedDevice = device;
                        writeStream = bluetoothSocket.getOutputStream();

                        new Handler(Looper.getMainLooper()).post(() -> {
                            final HashMap<String, Object> map = new HashMap<>();
                            map.put("id", 1);
                            channel.invokeMethod("onStateChanged", map);
                            result.success(true);
                        });
                    } catch (Exception e) {
                        new Handler(Looper.getMainLooper()).post(() -> {
                            result.error("error", e.getMessage(), null);
                        });
                    }
                });

                break;

            case "disconnect":
                AsyncTask.execute(() -> {
                    try {
                        writeStream.close();
                        bluetoothSocket.close();

                        connectedDevice = null;

                        new Handler(Looper.getMainLooper()).post(() -> {
                            final HashMap<String, Object> map = new HashMap<>();
                            map.put("id", 3);
                            channel.invokeMethod("onStateChanged", map);
                            result.success(true);
                        });
                    } catch (Exception e) {
                        new Handler(Looper.getMainLooper()).post(() -> {
                            result.error("error", e.getMessage(), null);
                        });
                    }
                });
                break;

            case "print": {
                if (connectedDevice == null) {
                    result.error("error", "No connected devices", null);
                    return;
                }

                final byte[] bytes = (byte[]) call.arguments;
                AsyncTask.execute(() -> {
                    try {
                        writeStream.write(bytes);
                        writeStream.flush();

                        new Handler(Looper.getMainLooper()).post(() -> {
                            result.success(true);

                            final HashMap<String, Object> map = new HashMap<>();
                            map.put("total", bytes.length);
                            map.put("progress", bytes.length);
                            channel.invokeMethod("onPrintingProgress", map);
                        });
                    } catch (Exception e) {
                        new Handler(Looper.getMainLooper()).post(() -> {
                            result.error("error", e.getMessage(), null);
                        });
                        e.printStackTrace();
                    }
                });
            }
            break;

            default:
                result.notImplemented();
                break;
        }
    }

    private void isEnabled(MethodChannel.Result result) {
        if (!isPermitted(result)) {
            return;
        }

        final boolean isEnabled = bluetoothAdapter.isEnabled();
        result.success(isEnabled);
    }

    private boolean isPermitted(Result result) {
        String[] permissions = {Manifest.permission.BLUETOOTH, Manifest.permission.BLUETOOTH_ADMIN, Manifest.permission.ACCESS_FINE_LOCATION};
        if (SDK_INT >= Build.VERSION_CODES.M) {
            activity.requestPermissions(permissions, 1);
            final int res = activity.checkSelfPermission(Manifest.permission.BLUETOOTH);
            final int per = activity.checkSelfPermission(Manifest.permission.BLUETOOTH_ADMIN);
            final  int per1 = activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION);
            if (res != PackageManager.PERMISSION_GRANTED && per != PackageManager.PERMISSION_GRANTED&& per1 != PackageManager.PERMISSION_GRANTED) {
                result.error("permission_denied", "Permission denied", null);
                return false;
            }
            return true;
        }
        return true;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        activity.registerReceiver(receiver, filter);

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }


    @Override
    public void onAttachedToBroadcastReceiver(@NonNull BroadcastReceiverPluginBinding binding) {
    }

    @Override
    public void onDetachedFromBroadcastReceiver() {

    }


}
