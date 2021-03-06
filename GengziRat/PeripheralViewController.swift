/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to view details of a CBPeripheral.
*/

import CoreBluetooth
import UIKit
import os.log

class PeripheralViewController: UIViewController {
    @IBOutlet internal var pTableView: UITableView!
	var cbManager: CBCentralManager?
    var selectedPeripheral: CBPeripheral?
    var readCharacter: CBCharacteristic?
    var writeCharacter: CBCharacteristic?
    var protocType: BTCProtoType = BTCProtoType.nullDefault
    
    let protobufIns = BLEProtobuf.init()
    let iwownIns = BLEIwown.init()

	private var peripheralConnectedState = false
        
    let arrS = ["DEVICE CONFIG","HWOption","SET&READ","DATA SYNC","MESSAGE"];
    let bleCmds = [["Device Info","DEVICE CONFIG","Dev tmp"],
                   ["HWOption","Schedule&Clock","Custom Option","Sedentary","Motor"],
                   ["Date Time","More"],
                   ["Summary Data","Sysc More"],
                   ["Push String","Black List"]];

    override func viewDidLoad() {
        super.viewDidLoad()
		pTableView.dataSource = self
        pTableView.delegate = self
        pTableView.reloadData()
        
        self.initUI()
        protobufIns.bpbDelegate = self
        
        // Set peripheral delegate
        selectedPeripheral?.delegate = self
		cbManager?.delegate = self
        os_log("Conenect selectedPeripheral : %@", selectedPeripheral ?? "nil")
		cbManager?.connect(selectedPeripheral!, options: nil)
    }
    
    func tableFootView() -> UIView {
        let vi = UIView.init(frame: CGRect(x:0,y:0,width: Int(SCREEN_WIDTH),height: 250))
        
        let footLabel = UILabel.init(frame: CGRect(x:0,y:0,width: Int(SCREEN_WIDTH),height: 50))
        footLabel.font = UIFont.systemFont(ofSize: 15)
        footLabel.textColor = UIColor.lightGray
        footLabel.textAlignment = NSTextAlignment.center
        footLabel.text = "-- 科技向善 希望至美 --"
        
        vi.addSubview(footLabel)
        return vi
    }
    
    func initUI() -> Void {
        pTableView.tableFooterView = self.tableFootView()
        let item=UIBarButtonItem(title: "Logs", style: UIBarButtonItem.Style.plain, target: self, action: #selector(showDeviceLogs))
        self.navigationItem.rightBarButtonItem=item
    }
    
    @objc func showDeviceLogs() -> Void {
        let logVC = LogsViewController.init()
        self.present(logVC, animated: true) {
            print("Show logs")
        }
    }
}

// MARK: - UITableViewDataSource
extension PeripheralViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bleCmds[section].count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "attributeCell", for: indexPath)
        cell.textLabel?.text = bleCmds[indexPath.section][indexPath.row]
		return cell
	}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return bleCmds.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrS[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if writeCharacter == nil {
            return
        }
        switch indexPath.section {
        case 0:
            self.selectCellAtZero(indexRow: indexPath.row)
            break
        case 1:
            self.selectCellAtOne(indexRow: indexPath.row)
            break
        case 2:
            self.selectCellAtTwo(indexRow: indexPath.row)
            break
        case 3:
            self.selectCellAtThree(indexRow: indexPath.row)
            break
        case 4:
            self.selectCellAtFour(indexRow: indexPath.row)
            break
        default:
            break
        }
    }
    
    func selectCellAtZero(indexRow : Int) {
        switch indexRow {
        case 0:
            let data = protobufIns.getDeviceInfo()
            selectedPeripheral?.writeValue(data, for: writeCharacter!, type: CBCharacteristicWriteType.withoutResponse)
            break
        case 1:
            let vc = DConfigViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 2:
            break
        default:
            break
        }
    }
    
    func selectCellAtOne(indexRow : Int) {
        switch (indexRow) {
        case 0:
            let vc = HWOptionController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break;
        case 1:
            let vc = ClockViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break;
        case 2:
            let vc = CHOptionController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 3:
            let vc = SedentaryViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case 4:
            let mv:PB_MotorVibrate = PB_MotorVibrate(mode: MotorShakeWay.Light, round: 3)
            let data = protobufIns.getMotorConf(vCnf: mv)
            selectedPeripheral?.writeValue(data, for: writeCharacter!, type: CBCharacteristicWriteType.withoutResponse)
            
            let vc:PB_VibrateCnf = PB_VibrateCnf.init(type: PB_VibrateType.sms, mode: MotorShakeWay.Light, round: 5)
            let mc:PB_MotorConf = PB_MotorConf.init(conf: [vc])
            let mData = protobufIns.getMotorConf(motorConf: mc)
            selectedPeripheral?.writeValue(mData, for: writeCharacter!, type: CBCharacteristicWriteType.withoutResponse)

            break
        default:
            break;
        }
    }
    
    func selectCellAtTwo(indexRow : Int) {
        switch (indexRow) {
        case 0:
            break;
        case 1:
            let vc = MoreViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break;
            
        default:
            break;
        }
    }
    
    func selectCellAtThree(indexRow : Int) {
        switch (indexRow) {
        case 0:
            let data = protobufIns.getRealTimeData()
            selectedPeripheral?.writeValue(data, for: writeCharacter!, type: CBCharacteristicWriteType.withoutResponse)
            break;
        case 1:
            let vc = DataViewController.init()
            vc.pVC = self
            self.navigationController?.pushViewController(vc, animated: true)
            break;
        case 2:
            
            break;
        default:
            break;
        }
    }
    
    func selectCellAtFour(indexRow : Int) {
        switch (indexRow) {
        case 0:
            break;
        case 1:
            let vc = BlackListViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
            break;
            
        default:
            break;
        }
    }
}

extension PeripheralViewController: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		os_log("peripheral: %@ connected", peripheral)
        self.title = peripheral.name
        let arr = [BTCProto.protobuf.sampleServiceUUID!,
                   BTCProto.iwown.sampleServiceUUID!]
        peripheral.discoverServices(arr)
	}

	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		os_log("peripheral: %@ failed to connect", peripheral)
	}

	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		os_log("peripheral: %@ disconnected", peripheral)
        self.title = "NULL"
		// Clean up cached peripheral state
	}
}

extension PeripheralViewController: CBPeripheralDelegate {
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		guard let service = peripheral.services?.first else {
			if let error = error {
				os_log("Error discovering service: %@", "\(error)")
			}
			return
		}
        for scSer in peripheral.services ?? [] {
            let btcI = BTCInsProtoc.instanceProtocol(uuidStr: scSer.uuid.uuidString)
            if btcI != BTCProtoType.nullDefault {
                protocType = btcI
            }
        }
        os_log("Discovered services %@", peripheral.services ?? [])
        peripheral.discoverCharacteristics(nil, for: service)
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		guard let characteristics = service.characteristics else {
			if let error = error {
				os_log("Error discovering characteristic: %@", "\(error)")
			}
			return
		}
        os_log("Discovered characteristics %@", characteristics)
        for character in characteristics {
            switch character.uuid {
            case BTCProto.protobuf.sampleCharacteristicNotifyUUID:
                peripheral.setNotifyValue(true, for: character)
            case BTCProto.protobuf.sampleCharacteristicWriteUUID:
                writeCharacter = character
            case BTCProto.iwown.sampleCharacteristicNotifyUUID:
                peripheral.setNotifyValue(true, for: character)
            case BTCProto.iwown.sampleCharacteristicWriteUUID:
                writeCharacter = character
            default:
                break
            }
        }
	}

	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value as Data? else {
            os_log("Unable to determine the characteristic's value.")
            return
        }
        protobufIns.braceletCmdReceive(data: value)
	}

	func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		// Accessory's GATT database has updated. Refresh your local cache (if any)
	}
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        selectedPeripheral = peripheral
        readCharacter = characteristic
        os_log("didUpdateNotificationStateFor: %@ - %@", peripheral, characteristic)
    }
}

extension PeripheralViewController: BleProtobufDelegate {
    func bleProtobufDidRecieveDeviceInfo(deviceInfo: PB_DeivceInfo) {
        print("bleProtobufDidRecieveDeviceInfo \(deviceInfo)")
    }
    
    func bleProtobufDidRecieveBatteryInfo(batteryInfo: PB_BatteryInfo) {
        print("bleProtobufDidRecieveBatteryInfo \(batteryInfo)")
    }
    
    func bleProtobufDidRecieveRealTimeData(rtData: PB_HealthSummary) {
        print("bleProtobufDidRecieveRealTimeData \(rtData)")
    }
    
    func bleProtobufDidRecieveDataIndexTable(type: PB_HisDatatype, indexTables: [PB_HisIndexTable]) {
        print("bleProtobufDidRecieveDataIndexTable \(type) \(indexTables)")
    }
    
    func bleProtobufDidRecieveData(type: PB_HisDatatype, hisData: PB_HisData) {
        print("bleProtobufDidRecieveData \(type) \(hisData)")
    }
}
