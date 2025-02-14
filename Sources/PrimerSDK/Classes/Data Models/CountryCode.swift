#if canImport(UIKit)

// inspired by https://gist.github.com/proxpero/f7ddfd721a0d0d6159589916185d9dc9

public enum CountryCode: String, Codable, CaseIterable {
    case af = "AF"
    case ax = "AX"
    case al = "AL"
    case dz = "DZ"
    case `as` = "AS"
    case ad = "AD"
    case ao = "AO"
    case ai = "AI"
    case aq = "AQ"
    case ag = "AG"
    case ar = "AR"
    case am = "AM"
    case aw = "AW"
    case au = "AU"
    case at = "AT"
    case az = "AZ"
    case bs = "BS"
    case bh = "BH"
    case bd = "BD"
    case bb = "BB"
    case by = "BY"
    case be = "BE"
    case bz = "BZ"
    case bj = "BJ"
    case bm = "BM"
    case bt = "BT"
    case bo = "BO"
    case bq = "BQ"
    case ba = "BA"
    case bw = "BW"
    case bv = "BV"
    case br = "BR"
    case io = "IO"
    case bn = "BN"
    case bg = "BG"
    case bf = "BF"
    case bi = "BI"
    case cv = "CV"
    case kh = "KH"
    case cm = "CM"
    case ca = "CA"
    case ky = "KY"
    case cf = "CF"
    case td = "TD"
    case cl = "CL"
    case cn = "CN"
    case cx = "CX"
    case cc = "CC"
    case co = "CO"
    case km = "KM"
    case cg = "CG"
    case cd = "CD"
    case ck = "CK"
    case cr = "CR"
    case ci = "CI"
    case hr = "HR"
    case cu = "CU"
    case cw = "CW"
    case cy = "CY"
    case cz = "CZ"
    case dk = "DK"
    case dj = "DJ"
    case dm = "DM"
    case `do` = "DO"
    case ec = "EC"
    case eg = "EG"
    case sv = "SV"
    case gq = "GQ"
    case er = "ER"
    case ee = "EE"
    case et = "ET"
    case fk = "FK"
    case fo = "FO"
    case fj = "FJ"
    case fi = "FI"
    case fr = "FR"
    case gf = "GF"
    case pf = "PF"
    case tf = "TF"
    case ga = "GA"
    case gm = "GM"
    case ge = "GE"
    case de = "DE"
    case gh = "GH"
    case gi = "GI"
    case gr = "GR"
    case gl = "GL"
    case gd = "GD"
    case gp = "GP"
    case gu = "GU"
    case gt = "GT"
    case gg = "GG"
    case gn = "GN"
    case gw = "GW"
    case gy = "GY"
    case ht = "HT"
    case hm = "HM"
    case va = "VA"
    case hn = "HN"
    case hk = "HK"
    case hu = "HU"
    case `is` = "IS"
    case `in` = "IN"
    case id = "ID"
    case ir = "IR"
    case iq = "IQ"
    case ie = "IE"
    case im = "IM"
    case il = "IL"
    case it = "IT"
    case jm = "JM"
    case jp = "JP"
    case je = "JE"
    case jo = "JO"
    case kz = "KZ"
    case ke = "KE"
    case ki = "KI"
    case kp = "KP"
    case kr = "KR"
    case kw = "KW"
    case kg = "KG"
    case la = "LA"
    case lv = "LV"
    case lb = "LB"
    case ls = "LS"
    case lr = "LR"
    case ly = "LY"
    case li = "LI"
    case lt = "LT"
    case lu = "LU"
    case mo = "MO"
    case mk = "MK"
    case mg = "MG"
    case mw = "MW"
    case my = "MY"
    case mv = "MV"
    case ml = "ML"
    case mt = "MT"
    case mh = "MH"
    case mq = "MQ"
    case mr = "MR"
    case mu = "MU"
    case yt = "YT"
    case mx = "MX"
    case fm = "FM"
    case md = "MD"
    case mc = "MC"
    case mn = "MN"
    case me = "ME"
    case ms = "MS"
    case ma = "MA"
    case mz = "MZ"
    case mm = "MM"
    case na = "NA"
    case nr = "NR"
    case np = "NP"
    case nl = "NL"
    case nc = "NC"
    case nz = "NZ"
    case ni = "NI"
    case ne = "NE"
    case ng = "NG"
    case nu = "NU"
    case nf = "NF"
    case mp = "MP"
    case no = "NO"
    case om = "OM"
    case pk = "PK"
    case pw = "PW"
    case ps = "PS"
    case pa = "PA"
    case pg = "PG"
    case py = "PY"
    case pe = "PE"
    case ph = "PH"
    case pn = "PN"
    case pl = "PL"
    case pt = "PT"
    case pr = "PR"
    case qa = "QA"
    case re = "RE"
    case ro = "RO"
    case ru = "RU"
    case rw = "RW"
    case bl = "BL"
    case sh = "SH"
    case kn = "KN"
    case lc = "LC"
    case mf = "MF"
    case pm = "PM"
    case vc = "VC"
    case ws = "WS"
    case sm = "SM"
    case st = "ST"
    case sa = "SA"
    case sn = "SN"
    case rs = "RS"
    case sc = "SC"
    case sl = "SL"
    case sg = "SG"
    case sx = "SX"
    case sk = "SK"
    case si = "SI"
    case sb = "SB"
    case so = "SO"
    case za = "ZA"
    case gs = "GS"
    case ss = "SS"
    case es = "ES"
    case lk = "LK"
    case sd = "SD"
    case sr = "SR"
    case sj = "SJ"
    case sz = "SZ"
    case se = "SE"
    case ch = "CH"
    case sy = "SY"
    case tw = "TW"
    case tj = "TJ"
    case tz = "TZ"
    case th = "TH"
    case tl = "TL"
    case tg = "TG"
    case tk = "TK"
    case to = "TO"
    case tt = "TT"
    case tn = "TN"
    case tr = "TR"
    case tm = "TM"
    case tc = "TC"
    case tv = "TV"
    case ug = "UG"
    case ua = "UA"
    case ae = "AE"
    case gb = "GB"
    case us = "US"
    case um = "UM"
    case uy = "UY"
    case uz = "UZ"
    case vu = "VU"
    case ve = "VE"
    case vn = "VN"
    case vg = "VG"
    case vi = "VI"
    case wf = "WF"
    case eh = "EH"
    case ye = "YE"
    case zm = "ZM"
    case zw = "ZW"
}

internal extension CountryCode {

    static var all: [CountryCode] = [.af, .ax, .al, .dz, .`as`, .ad, .ao, .ai, .aq, .ag, .ar, .am, .aw, .au, .at, .az, .bs, .bh, .bd, .bb, .by, .be, .bz, .bj, .bm, .bt, .bo, .bq, .ba, .bw, .bv, .br, .io, .bn, .bg, .bf, .bi, .cv, .kh, .cm, .ca, .ky, .cf, .td, .cl, .cn, .cx, .cc, .co, .km, .cg, .cd, .ck, .cr, .ci, .hr, .cu, .cw, .cy, .cz, .dk, .dj, .dm, .`do`, .ec, .eg, .sv, .gq, .er, .ee, .et, .fk, .fo, .fj, .fi, .fr, .gf, .pf, .tf, .ga, .gm, .ge, .de, .gh, .gi, .gr, .gl, .gd, .gp, .gu, .gt, .gg, .gn, .gw, .gy, .ht, .hm, .va, .hn, .hk, .hu, .`is`, .`in`, .id, .ir, .iq, .ie, .im, .il, .it, .jm, .jp, .je, .jo, .kz, .ke, .ki, .kp, .kr, .kw, .kg, .la, .lv, .lb, .ls, .lr, .ly, .li, .lt, .lu, .mo, .mk, .mg, .mw, .my, .mv, .ml, .mt, .mh, .mq, .mr, .mu, .yt, .mx, .fm, .md, .mc, .mn, .me, .ms, .ma, .mz, .mm, .na, .nr, .np, .nl, .nc, .nz, .ni, .ne, .ng, .nu, .nf, .mp, .no, .om, .pk, .pw, .ps, .pa, .pg, .py, .pe, .ph, .pn, .pl, .pt, .pr, .qa, .re, .ro, .ru, .rw, .bl, .sh, .kn, .lc, .mf, .pm, .vc, .ws, .sm, .st, .sa, .sn, .rs, .sc, .sl, .sg, .sx, .sk, .si, .sb, .so, .za, .gs, .ss, .es, .lk, .sd, .sr, .sj, .sz, .se, .ch, .sy, .tw, .tj, .tz, .th, .tl, .tg, .tk, .to, .tt, .tn, .tr, .tm, .tc, .tv, .ug, .ua, .ae, .gb, .us, .um, .uy, .uz, .vu, .ve, .vn, .vg, .vi, .wf, .eh, .ye, .zm, .zw]

    var country: String {
        switch self {
        case .af: return "Afghanistan"
        case .ax: return "Åland Islands"
        case .al: return "Albania"
        case .dz: return "Algeria"
        case .as: return "American Samoa"
        case .ad: return "Andorra"
        case .ao: return "Angola"
        case .ai: return "Anguilla"
        case .aq: return "Antarctica"
        case .ag: return "Antigua and Barbuda"
        case .ar: return "Argentina"
        case .am: return "Armenia"
        case .aw: return "Aruba"
        case .au: return "Australia"
        case .at: return "Austria"
        case .az: return "Azerbaijan"
        case .bs: return "Bahamas"
        case .bh: return "Bahrain"
        case .bd: return "Bangladesh"
        case .bb: return "Barbados"
        case .by: return "Belarus"
        case .be: return "Belgium"
        case .bz: return "Belize"
        case .bj: return "Benin"
        case .bm: return "Bermuda"
        case .bt: return "Bhutan"
        case .bo: return "Bolivia (Plurinational State of)"
        case .bq: return "Bonaire, Sint Eustatius and Saba"
        case .ba: return "Bosnia and Herzegovina"
        case .bw: return "Botswana"
        case .bv: return "Bouvet Island"
        case .br: return "Brazil"
        case .io: return "British Indian Ocean Territory"
        case .bn: return "Brunei Darussalam"
        case .bg: return "Bulgaria"
        case .bf: return "Burkina Faso"
        case .bi: return "Burundi"
        case .cv: return "Cabo Verde"
        case .kh: return "Cambodia"
        case .cm: return "Cameroon"
        case .ca: return "Canada"
        case .ky: return "Cayman Islands"
        case .cf: return "Central African Republic"
        case .td: return "Chad"
        case .cl: return "Chile"
        case .cn: return "China"
        case .cx: return "Christmas Island"
        case .cc: return "Cocos (Keeling) Islands"
        case .co: return "Colombia"
        case .km: return "Comoros"
        case .cg: return "Congo"
        case .cd: return "Congo (Democratic Republic of the)"
        case .ck: return "Cook Islands"
        case .cr: return "Costa Rica"
        case .ci: return "Côte d'Ivoire"
        case .hr: return "Croatia"
        case .cu: return "Cuba"
        case .cw: return "Curaçao"
        case .cy: return "Cyprus"
        case .cz: return "Czechia"
        case .dk: return "Denmark"
        case .dj: return "Djibouti"
        case .dm: return "Dominica"
        case .do: return "Dominican Republic"
        case .ec: return "Ecuador"
        case .eg: return "Egypt"
        case .sv: return "El Salvador"
        case .gq: return "Equatorial Guinea"
        case .er: return "Eritrea"
        case .ee: return "Estonia"
        case .et: return "Ethiopia"
        case .fk: return "Falkland Islands (Malvinas)"
        case .fo: return "Faroe Islands"
        case .fj: return "Fiji"
        case .fi: return "Finland"
        case .fr: return "France"
        case .gf: return "French Guiana"
        case .pf: return "French Polynesia"
        case .tf: return "French Southern Territories"
        case .ga: return "Gabon"
        case .gm: return "Gambia"
        case .ge: return "Georgia"
        case .de: return "Germany"
        case .gh: return "Ghana"
        case .gi: return "Gibraltar"
        case .gr: return "Greece"
        case .gl: return "Greenland"
        case .gd: return "Grenada"
        case .gp: return "Guadeloupe"
        case .gu: return "Guam"
        case .gt: return "Guatemala"
        case .gg: return "Guernsey"
        case .gn: return "Guinea"
        case .gw: return "Guinea-Bissau"
        case .gy: return "Guyana"
        case .ht: return "Haiti"
        case .hm: return "Heard Island and McDonald Islands"
        case .va: return "Holy See"
        case .hn: return "Honduras"
        case .hk: return "Hong Kong"
        case .hu: return "Hungary"
        case .is: return "Iceland"
        case .in: return "India"
        case .id: return "Indonesia"
        case .ir: return "Iran (Islamic Republic of)"
        case .iq: return "Iraq"
        case .ie: return "Ireland"
        case .im: return "Isle of Man"
        case .il: return "Israel"
        case .it: return "Italy"
        case .jm: return "Jamaica"
        case .jp: return "Japan"
        case .je: return "Jersey"
        case .jo: return "Jordan"
        case .kz: return "Kazakhstan"
        case .ke: return "Kenya"
        case .ki: return "Kiribati"
        case .kp: return "Korea (Democratic People's Republic of)"
        case .kr: return "Korea (Republic of)"
        case .kw: return "Kuwait"
        case .kg: return "Kyrgyzstan"
        case .la: return "Lao People's Democratic Republic"
        case .lv: return "Latvia"
        case .lb: return "Lebanon"
        case .ls: return "Lesotho"
        case .lr: return "Liberia"
        case .ly: return "Libya"
        case .li: return "Liechtenstein"
        case .lt: return "Lithuania"
        case .lu: return "Luxembourg"
        case .mo: return "Macao"
        case .mk: return "Macedonia (the former Yugoslav Republic of)"
        case .mg: return "Madagascar"
        case .mw: return "Malawi"
        case .my: return "Malaysia"
        case .mv: return "Maldives"
        case .ml: return "Mali"
        case .mt: return "Malta"
        case .mh: return "Marshall Islands"
        case .mq: return "Martinique"
        case .mr: return "Mauritania"
        case .mu: return "Mauritius"
        case .yt: return "Mayotte"
        case .mx: return "Mexico"
        case .fm: return "Micronesia (Federated States of)"
        case .md: return "Moldova (Republic of)"
        case .mc: return "Monaco"
        case .mn: return "Mongolia"
        case .me: return "Montenegro"
        case .ms: return "Montserrat"
        case .ma: return "Morocco"
        case .mz: return "Mozambique"
        case .mm: return "Myanmar"
        case .na: return "Namibia"
        case .nr: return "Nauru"
        case .np: return "Nepal"
        case .nl: return "Netherlands"
        case .nc: return "New Caledonia"
        case .nz: return "New Zealand"
        case .ni: return "Nicaragua"
        case .ne: return "Niger"
        case .ng: return "Nigeria"
        case .nu: return "Niue"
        case .nf: return "Norfolk Island"
        case .mp: return "Northern Mariana Islands"
        case .no: return "Norway"
        case .om: return "Oman"
        case .pk: return "Pakistan"
        case .pw: return "Palau"
        case .ps: return "Palestine, State of"
        case .pa: return "Panama"
        case .pg: return "Papua New Guinea"
        case .py: return "Paraguay"
        case .pe: return "Peru"
        case .ph: return "Philippines"
        case .pn: return "Pitcairn"
        case .pl: return "Poland"
        case .pt: return "Portugal"
        case .pr: return "Puerto Rico"
        case .qa: return "Qatar"
        case .re: return "Réunion"
        case .ro: return "Romania"
        case .ru: return "Russian Federation"
        case .rw: return "Rwanda"
        case .bl: return "Saint Barthélemy"
        case .sh: return "Saint Helena, Ascension and Tristan da Cunha"
        case .kn: return "Saint Kitts and Nevis"
        case .lc: return "Saint Lucia"
        case .mf: return "Saint Martin (French part)"
        case .pm: return "Saint Pierre and Miquelon"
        case .vc: return "Saint Vincent and the Grenadines"
        case .ws: return "Samoa"
        case .sm: return "San Marino"
        case .st: return "Sao Tome and Principe"
        case .sa: return "Saudi Arabia"
        case .sn: return "Senegal"
        case .rs: return "Serbia"
        case .sc: return "Seychelles"
        case .sl: return "Sierra Leone"
        case .sg: return "Singapore"
        case .sx: return "Sint Maarten (Dutch part)"
        case .sk: return "Slovakia"
        case .si: return "Slovenia"
        case .sb: return "Solomon Islands"
        case .so: return "Somalia"
        case .za: return "South Africa"
        case .gs: return "South Georgia and the South Sandwich Islands"
        case .ss: return "South Sudan"
        case .es: return "Spain"
        case .lk: return "Sri Lanka"
        case .sd: return "Sudan"
        case .sr: return "Suriname"
        case .sj: return "Svalbard and Jan Mayen"
        case .sz: return "Swaziland"
        case .se: return "Sweden"
        case .ch: return "Switzerland"
        case .sy: return "Syrian Arab Republic"
        case .tw: return "Taiwan, Province of China[a]"
        case .tj: return "Tajikistan"
        case .tz: return "Tanzania, United Republic of"
        case .th: return "Thailand"
        case .tl: return "Timor-Leste"
        case .tg: return "Togo"
        case .tk: return "Tokelau"
        case .to: return "Tonga"
        case .tt: return "Trinidad and Tobago"
        case .tn: return "Tunisia"
        case .tr: return "Turkey"
        case .tm: return "Turkmenistan"
        case .tc: return "Turks and Caicos Islands"
        case .tv: return "Tuvalu"
        case .ug: return "Uganda"
        case .ua: return "Ukraine"
        case .ae: return "United Arab Emirates"
        case .gb: return "United Kingdom of Great Britain and Northern Ireland"
        case .us: return "United States of America"
        case .um: return "United States Minor Outlying Islands"
        case .uy: return "Uruguay"
        case .uz: return "Uzbekistan"
        case .vu: return "Vanuatu"
        case .ve: return "Venezuela (Bolivarian Republic of)"
        case .vn: return "Viet Nam"
        case .vg: return "Virgin Islands (British)"
        case .vi: return "Virgin Islands (U.S.)"
        case .wf: return "Wallis and Futuna"
        case .eh: return "Western Sahara"
        case .ye: return "Yemen"
        case .zm: return "Zambia"
        case .zw: return "Zimbabwe"
        }
    }

    var flag: String {
        let unicodeScalars = self.rawValue
            .unicodeScalars
            .map { $0.value + 0x1F1E6 - 65 }
            .compactMap(UnicodeScalar.init)
        var result = ""
        result.unicodeScalars.append(contentsOf: unicodeScalars)
        return result
    }

}

extension CountryCode {

    // todo: enable locale for local languages too.
    // reference: https://developers.klarna.com/documentation/klarna-payments/in-depth-knowledge/puchase-countries-currencies-locales/
    var klarnaLocaleCode: String {
        switch self {
        case .at, .dk, .fi, .de, .nl, .no, .se, .ch, .us, .au, .gb:
            return "en-\(self.rawValue)"
        case .be:
            return "fr-BE"
        case .es:
            return "es-ES"
        case .it:
            return "it-IT"
        default:
            return "n/a"
        }
    }

}

#endif
