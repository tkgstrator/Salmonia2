import Foundation

@dynamicMemberLookup
public enum WeaponType: CaseIterable {
    case w2, w1, w0, w10, w1000, w1010, w1020, w1030, w1100, w1110, w20, w200, w2000, w20000, w20010, w20020, w20030, w2010, w2020,
         w2030, w2040, w2050, w2060, w210, w220, w230, w240, w250, w30, w300, w3000, w3010, w3020, w3030, w3040, w310, w40, w400, w4000, w4010,
         w4020, w4030, w4040, w50, w5000, w5010, w5020, w5030, w5040, w60, w6000, w6010, w6020, w70, w80, w90
}

public enum WeaponTypeURL: String, CaseIterable {
    case w2 = "7076c8181ab5c49d2ac91e43a2d945a46a99c17d.png"
    case w1 = "746f7e90bc151334f0bf0d2a1f0987e311b03736.png"
    case w0 = "32d41a5d14de756c3e5a1ee97a9bd8fcb9e69bf5.png"
    case w10 = "91b6666bcbfccc204d86f21222a8db22a27d08d0.png"
    case w1000 = "123db7c37066e10e2c437656db2a26f18898e6b6.png"
    case w1010 = "1041dbdd11b3036671148d47c2e0798cecf3dba2.png"
    case w1020 = "3d274190988ad20dd1b02825448edbb6e12c720c.png"
    case w1030 = "e32ed68bb18628c5ede5816a2fbc2b8fcdd04124.png"
    case w1100 = "1f94c29067c918ac9143b756dc607ff0f8cf4e63.png"
    case w1110 = "f1d5740dfb7d87f7e43974bbe5585445368741b8.png"
    case w20 = "e5a97d52f12a83a037526588363021f2c1f718b0.png"
    case w200 = "3f840ce3cc5ac0b8cbf7451079b57e807d8b95f1.png"
    case w2000 = "5a0a20324f1374a363363d721a605849e36ffff2.png"
    case w20000 = "db39203d81d60a7370d3ae966bc02ed14398366f.png"
    case w20010 = "7d5ff3a57c3c3aaf28217bc3a79e02d665f13ba7.png"
    case w20020 = "95077fe72924bcd64f37cd43aa49a12cd6329a7e.png"
    case w20030 = "c2c0653d3246ea6df2b595c68e907f68eda49b08.png"
    case w2010 = "1ed94885bef2b0e498ed4dd76bea9064c85cfc94.png"
    case w2020 = "0ec07bb00918f071975b35191e0860152bdcb321.png"
    case w2030 = "a6279990ad871fccdd9f2a64a2951f8726f45c48.png"
    case w2040 = "fd4b89e84b375f01290185f2236dbee935dd1682.png"
    case w2050 = "6ecbbb897d6c59a5c03097216ef4f803366ea6fa.png"
    case w2060 = "26d523e6eee3d57dc6c5f531dfc1747ffd46b8b8.png"
    case w210 = "cfafc8bc42bcd89058fdb22b7b943fb9f893adb8.png"
    case w220 = "109b2b851481510eaacb50afc8ce9fb79b7f20ad.png"
    case w230 = "2b684d81508ca5286060767e29dd81ca38303f43.png"
    case w240 = "72bdcf5f6077bd7149832153034b3f43d16ac461.png"
    case w250 = "8f64580bb033ba86fa0179179cfeb56b5544fda6.png"
    case w30 = "c6ab7ebff7af7f7604eb53a12851da880b1ec2c7.png"
    case w300 = "202724be5bb5e59457227d087d7c48a32c01db24.png"
    case w3000 = "3963a3fb1ff8038a42072e913587fc6f9aa00d71.png"
    case w3010 = "ad921a57ab1b7721c50873c082bb34591b61021c.png"
    case w3020 = "27a026e7dec5a068777bb7883f50451aec799d71.png"
    case w3030 = "2835f6d61a4296b4ac3876337884a0c453a4fa4f.png"
    case w3040 = "bf0d4b5ddc35a533fc5080d025707f386b2a5daa.png"
    case w310 = "45e8847cbaf09bdc86c6e6627236286781b09f0f.png"
    case w40 = "e1d09fc9502a81c82137c8dcd5a872eb872af697.png"
    case w400 = "b9901d49ef3229d3e62d58fc3e1edc8c48da6873.png"
    case w4000 = "2a1c5ca0e68919b4d655bd860cac3b2942b95498.png"
    case w4010 = "6f42c9f8fde07510a01072a669125545f6effb99.png"
    case w4020 = "e34bbd580e49695b97d5fc4464cc901d4fe08ce5.png"
    case w4030 = "f208b6222acb5014ab96285e9b9a3e98039c884b.png"
    case w4040 = "d79b99092aa03dc249b1f767197c1ecbda9d3cd7.png"
    case w50 = "df04ddaf086cea94491df553a6d2550230a4da3c.png"
    case w5000 = "cc4bc30ff53bf2b45bd5e3dadceb39d52b95761f.png"
    case w5010 = "bb5caf24e43f8c7ceb126670bf24fd3aa9a3c3fc.png"
    case w5020 = "7d6032f0ceee14c4607385b848c6e486b84a2865.png"
    case w5030 = "aaead5ff0b63cdcb989b211d649b2552bb3e3a1b.png"
    case w5040 = "ba750d284eb067abdc995435c3358eed4e6f90fa.png"
    case w60 = "1f2b1db5917ef7a4e62f0e15b8805275e33f2179.png"
    case w6000 = "f1fa6db2e21f32cd1c2cd093ec24f1a450d4650c.png"
    case w6010 = "cdb032aa993f4836580ce4edac06de0138833299.png"
    case w6020 = "15fe3fe6bbec24ddb5fdc3ffd06585bc82440531.png"
    case w70 = "2e2b59379b8f14cfed0600f84590be0ecad707b6.png"
    case w80 = "df90f6065594378690647c23d42440e2de89c99d.png"
    case w90 = "007fb7ed50e76dde495ffb0747421b50dfce8aa3.png"
}

public enum WeaponTypeID: Int, CaseIterable {
    case w2 = -2
    case w1 = -1
    case w0 = 0
    case w10 = 10
    case w1000 = 1000
    case w1010 = 1010
    case w1020 = 1020
    case w1030 = 1030
    case w1100 = 1100
    case w1110 = 1110
    case w20 = 20
    case w200 = 200
    case w2000 = 2000
    case w20000 = 20000
    case w20010 = 20010
    case w20020 = 20020
    case w20030 = 20030
    case w2010 = 2010
    case w2020 = 2020
    case w2030 = 2030
    case w2040 = 2040
    case w2050 = 2050
    case w2060 = 2060
    case w210 = 210
    case w220 = 220
    case w230 = 230
    case w240 = 240
    case w250 = 250
    case w30 = 30
    case w300 = 300
    case w3000 = 3000
    case w3010 = 3010
    case w3020 = 3020
    case w3030 = 3030
    case w3040 = 3040
    case w310 = 310
    case w40 = 40
    case w400 = 400
    case w4000 = 4000
    case w4010 = 4010
    case w4020 = 4020
    case w4030 = 4030
    case w4040 = 4040
    case w50 = 50
    case w5000 = 5000
    case w5010 = 5010
    case w5020 = 5020
    case w5030 = 5030
    case w5040 = 5040
    case w60 = 60
    case w6000 = 6000
    case w6010 = 6010
    case w6020 = 6020
    case w70 = 70
    case w80 = 80
    case w90 = 90
}

extension WeaponTypeID {
    var weapon_id: Int { rawValue }
}

extension WeaponTypeURL {
    var weapon_url: String { rawValue }
}

public extension WeaponType {
    init?(weapon_id: Int) {
        self.init(WeaponTypeID(rawValue: weapon_id))
    }
    
    init?(weapon_url: String) {
        self.init(WeaponTypeURL(rawValue: weapon_url))
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<WeaponTypeID, V>) -> V? {
        self[keyPath]
    }
    
    subscript<V>(dynamicMember keyPath: KeyPath<WeaponTypeURL, V>) -> V? {
        self[keyPath]
    }
    
    var image_url: URL {
        switch self.weapon_id! < 0 {
        case true:
            return URL(string: "https://app.splatoon2.nintendo.net/images/coop_weapons/\(self.weapon_url!)")!
        case false:
            return URL(string: "https://app.splatoon2.nintendo.net/images/weapon/\(self.weapon_url!)")!
        }
    }
}

private extension WeaponType {
    init?<T>(_ object: T?) where T: CaseIterable, T.AllCases.Index == AllCases.Index, T: Equatable {
        switch object {
        case let object? where object.offset < Self.allCases.endIndex:
            self = Self.allCases[object.offset]
        case _:
            return nil
        }
    }
    
    subscript<T, V>(_ keyPath: KeyPath<T, V>) -> V? where T: CaseIterable, T.AllCases.Index == AllCases.Index {
        (offset < T.allCases.endIndex) ? T.allCases[offset][keyPath: keyPath] : nil
    }
}
