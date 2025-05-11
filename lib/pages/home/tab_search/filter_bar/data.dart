// 结果数据类型
class FilterBarResult {
  final String? cityId; // 对应 Room.js city (通过 cityId 获取城市名)
  final String? districtId; // 对应 Room.js district (areaId 可能就是 districtId)
  final String? rentTypeId; // 对应 Room.js rentType
  final String? priceId; // 对应 Room.js price (priceId 需要映射到价格范围)
  final List<String>? roomTypeIds; // 对应 Room.js roomType (多选)
  final List<String>? orientationIds; // 对应 Room.js orientation (多选)
  final List<String>? floorIds; // 对应 Room.js floor (多选)
  final List<String>? tagIds; // 对应 Room.js tags (多选)

  FilterBarResult({
    this.cityId,
    this.districtId, // 替换旧的 areaId
    this.rentTypeId,
    this.priceId,
    this.roomTypeIds, // roomTypeIds, orientationIds, floorIds, tagIds 替换旧的 moreIds
    this.orientationIds,
    this.floorIds,
    this.tagIds,
  });

  // Helper to convert to a map, useful for query parameters
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (cityId != null && cityId!.isNotEmpty) map['city'] = cityId;
    if (districtId != null && districtId!.isNotEmpty) map['district'] = districtId;
    if (rentTypeId != null && rentTypeId!.isNotEmpty && rentTypeId!.toLowerCase() != '不限') map['rentType'] = rentTypeId; // 确保 "不限" 不被发送
    if (priceId != null && priceId!.isNotEmpty && priceId!.toLowerCase() != '不限') map['priceRange'] = priceId; // 修改 'price' 为 'priceRange'，并确保 "不限" 不被发送
    if (roomTypeIds != null && roomTypeIds!.isNotEmpty) map['roomType'] = roomTypeIds!.join(',');
    if (orientationIds != null && orientationIds!.isNotEmpty) map['orientation'] = orientationIds!.join(',');
    if (floorIds != null && floorIds!.isNotEmpty) map['floor'] = floorIds!.join(',');
    if (tagIds != null && tagIds!.isNotEmpty) map['tags'] = tagIds!.join(',');
    return map;
  }
}

// 通用类型
class GeneralType {
  final String name;
  final String id;

  GeneralType(this.name, this.id);
}

// 新的数据结构：城市及其区域信息
class CityAreaInfo {
  final String cityName;
  final List<GeneralType> districts;

  CityAreaInfo(this.cityName, this.districts);
}

/*
// 原有的 areaList，已由 cityAreaListData 替代
List<GeneralType> areaList = [
  GeneralType('不限', 'area_any'), // "不限" 选项通常是需要的
  // ... (之前大量的扁平化区域数据)
];
*/

// 新的城市区域数据列表
List<CityAreaInfo> cityAreaListData = [
  CityAreaInfo("北京市", [
    GeneralType('不限', 'beijing_area_any'),
    GeneralType('东城区', '东城区'), GeneralType('西城区', '西城区'), GeneralType('朝阳区', '朝阳区'), GeneralType('丰台区', '丰台区'), GeneralType('石景山区', '石景山区'), GeneralType('海淀区', '海淀区'), GeneralType('门头沟区', '门头沟区'), GeneralType('房山区', '房山区'), GeneralType('通州区', '通州区'), GeneralType('顺义区', '顺义区'), GeneralType('昌平区', '昌平区'), GeneralType('大兴区', '大兴区'), GeneralType('怀柔区', '怀柔区'), GeneralType('平谷区', '平谷区'), GeneralType('密云县', '密云县'), GeneralType('延庆县', '延庆县'),
  ]),
  CityAreaInfo("天津市", [
    GeneralType('不限', 'tianjin_area_any'),
    GeneralType('和平区', '和平区'), GeneralType('河东区', '河东区'), GeneralType('河西区', '河西区'), GeneralType('南开区', '南开区'), GeneralType('河北区', '河北区'), GeneralType('红桥区', '红桥区'), GeneralType('东丽区', '东丽区'), GeneralType('西青区', '西青区'), GeneralType('津南区', '津南区'), GeneralType('北辰区', '北辰区'), GeneralType('武清区', '武清区'), GeneralType('宝坻区', '宝坻区'), GeneralType('滨海新区', '滨海新区'), GeneralType('宁河县', '宁河县'), GeneralType('静海县', '静海县'), GeneralType('蓟县', '蓟县'),
  ]),
  CityAreaInfo("石家庄市", [
    GeneralType('不限', 'shijiazhuang_area_any'),
    GeneralType('长安区', '长安区'), GeneralType('桥东区', '桥东区'), GeneralType('桥西区', '桥西区'), GeneralType('新华区', '新华区'), GeneralType('井陉矿区', '井陉矿区'), GeneralType('裕华区', '裕华区'), GeneralType('井陉县', '井陉县'), GeneralType('正定县', '正定县'), GeneralType('栾城县', '栾城县'), GeneralType('行唐县', '行唐县'), GeneralType('灵寿县', '灵寿县'), GeneralType('高邑县', '高邑县'), GeneralType('深泽县', '深泽县'), GeneralType('赞皇县', '赞皇县'), GeneralType('无极县', '无极县'), GeneralType('平山县', '平山县'), GeneralType('元氏县', '元氏县'), GeneralType('赵县', '赵县'), GeneralType('辛集市', '辛集市'), GeneralType('藁城市', '藁城市'), GeneralType('晋州市', '晋州市'), GeneralType('新乐市', '新乐市'), GeneralType('鹿泉市', '鹿泉市'),
  ]),
  CityAreaInfo("唐山市", [
    GeneralType('不限', 'tangshan_area_any'),
    GeneralType('路南区', '路南区'), GeneralType('路北区', '路北区'), GeneralType('古冶区', '古冶区'), GeneralType('开平区', '开平区'), GeneralType('丰南区', '丰南区'), GeneralType('丰润区', '丰润区'), GeneralType('滦县', '滦县'), GeneralType('滦南县', '滦南县'), GeneralType('乐亭县', '乐亭县'), GeneralType('迁西县', '迁西县'), GeneralType('玉田县', '玉田县'), GeneralType('唐海县', '唐海县'), GeneralType('遵化市', '遵化市'), GeneralType('迁安市', '迁安市'),
  ]),
  CityAreaInfo("秦皇岛市", [
    GeneralType('不限', 'qinhuangdao_area_any'),
    GeneralType('海港区', '海港区'), GeneralType('山海关区', '山海关区'), GeneralType('北戴河区', '北戴河区'), GeneralType('青龙满族自治县', '青龙满族自治县'), GeneralType('昌黎县', '昌黎县'), GeneralType('抚宁县', '抚宁县'), GeneralType('卢龙县', '卢龙县'),
  ]),
  CityAreaInfo("邯郸市", [
    GeneralType('不限', 'handan_area_any'),
    GeneralType('邯山区', '邯山区'), GeneralType('丛台区', '丛台区'), GeneralType('复兴区', '复兴区'), GeneralType('峰峰矿区', '峰峰矿区'), GeneralType('邯郸县', '邯郸县'), GeneralType('临漳县', '临漳县'), GeneralType('成安县', '成安县'), GeneralType('大名县', '大名县'), GeneralType('涉县', '涉县'), GeneralType('磁县', '磁县'), GeneralType('肥乡县', '肥乡县'), GeneralType('永年县', '永年县'), GeneralType('邱县', '邱县'), GeneralType('鸡泽县', '鸡泽县'), GeneralType('广平县', '广平县'), GeneralType('馆陶县', '馆陶县'), GeneralType('魏县', '魏县'), GeneralType('曲周县', '曲周县'), GeneralType('武安市', '武安市'),
  ]),
  CityAreaInfo("邢台市", [
    GeneralType('不限', 'xingtai_area_any'),
    GeneralType('桥东区', '桥东区'), GeneralType('桥西区', '桥西区'), GeneralType('邢台县', '邢台县'), GeneralType('临城县', '临城县'), GeneralType('内丘县', '内丘县'), GeneralType('柏乡县', '柏乡县'), GeneralType('隆尧县', '隆尧县'), GeneralType('任县', '任县'), GeneralType('南和县', '南和县'), GeneralType('宁晋县', '宁晋县'), GeneralType('巨鹿县', '巨鹿县'), GeneralType('新河县', '新河县'), GeneralType('广宗县', '广宗县'), GeneralType('平乡县', '平乡县'), GeneralType('威县', '威县'), GeneralType('清河县', '清河县'), GeneralType('临西县', '临西县'), GeneralType('南宫市', '南宫市'), GeneralType('沙河市', '沙河市'),
  ]),
  CityAreaInfo("保定市", [
    GeneralType('不限', 'baoding_area_any'),
    GeneralType('新市区', '新市区'), GeneralType('北市区', '北市区'), GeneralType('南市区', '南市区'), GeneralType('满城县', '满城县'), GeneralType('清苑县', '清苑县'), GeneralType('涞水县', '涞水县'), GeneralType('阜平县', '阜平县'), GeneralType('徐水县', '徐水县'), GeneralType('定兴县', '定兴县'), GeneralType('唐县', '唐县'), GeneralType('高阳县', '高阳县'), GeneralType('容城县', '容城县'), GeneralType('涞源县', '涞源县'), GeneralType('望都县', '望都县'), GeneralType('安新县', '安新县'), GeneralType('易县', '易县'), GeneralType('曲阳县', '曲阳县'), GeneralType('蠡县', '蠡县'), GeneralType('顺平县', '顺平县'), GeneralType('博野县', '博野县'), GeneralType('雄县', '雄县'), GeneralType('涿州市', '涿州市'), GeneralType('定州市', '定州市'), GeneralType('安国市', '安国市'), GeneralType('高碑店市', '高碑店市'),
  ]),
  CityAreaInfo("张家口市", [
    GeneralType('不限', 'zhangjiakou_area_any'),
    GeneralType('桥东区', '桥东区'), GeneralType('桥西区', '桥西区'), GeneralType('宣化区', '宣化区'), GeneralType('下花园区', '下花园区'), GeneralType('宣化县', '宣化县'), GeneralType('张北县', '张北县'), GeneralType('康保县', '康保县'), GeneralType('沽源县', '沽源县'), GeneralType('尚义县', '尚义县'), GeneralType('蔚县', '蔚县'), GeneralType('阳原县', '阳原县'), GeneralType('怀安县', '怀安县'), GeneralType('万全县', '万全县'), GeneralType('怀来县', '怀来县'), GeneralType('涿鹿县', '涿鹿县'), GeneralType('赤城县', '赤城县'), GeneralType('崇礼县', '崇礼县'),
  ]),
  CityAreaInfo("承德市", [
    GeneralType('不限', 'chengde_hb_area_any'),
    GeneralType('双桥区', '双桥区'), GeneralType('双滦区', '双滦区'), GeneralType('鹰手营子矿区', '鹰手营子矿区'), GeneralType('承德县', '承德县'), GeneralType('兴隆县', '兴隆县'), GeneralType('平泉县', '平泉县'), GeneralType('滦平县', '滦平县'), GeneralType('隆化县', '隆化县'), GeneralType('丰宁满族自治县', '丰宁满族自治县'), GeneralType('宽城满族自治县', '宽城满族自治县'), GeneralType('围场满族蒙古族自治县', '围场满族蒙古族自治县'),
  ]),
  CityAreaInfo("沧州市", [
    GeneralType('不限', 'cangzhou_hb_area_any'),
    GeneralType('新华区', '新华区'), GeneralType('运河区', '运河区'), GeneralType('沧县', '沧县'), GeneralType('青县', '青县'), GeneralType('东光县', '东光县'), GeneralType('海兴县', '海兴县'), GeneralType('盐山县', '盐山县'), GeneralType('肃宁县', '肃宁县'), GeneralType('南皮县', '南皮县'), GeneralType('吴桥县', '吴桥县'), GeneralType('献县', '献县'), GeneralType('孟村回族自治县', '孟村回族自治县'), GeneralType('泊头市', '泊头市'), GeneralType('任丘市', '任丘市'), GeneralType('黄骅市', '黄骅市'), GeneralType('河间市', '河间市'),
  ]),
  CityAreaInfo("廊坊市", [
    GeneralType('不限', 'langfang_area_any'),
    GeneralType('安次区', '安次区'), GeneralType('广阳区', '广阳区'), GeneralType('固安县', '固安县'), GeneralType('永清县', '永清县'), GeneralType('香河县', '香河县'), GeneralType('大城县', '大城县'), GeneralType('文安县', '文安县'), GeneralType('大厂回族自治县', '大厂回族自治县'), GeneralType('霸州市', '霸州市'), GeneralType('三河市', '三河市'),
  ]),
  CityAreaInfo("衡水市", [
    GeneralType('不限', 'hengshui_area_any'),
    GeneralType('桃城区', '桃城区'), GeneralType('枣强县', '枣强县'), GeneralType('武邑县', '武邑县'), GeneralType('武强县', '武强县'), GeneralType('饶阳县', '饶阳县'), GeneralType('安平县', '安平县'), GeneralType('故城县', '故城县'), GeneralType('景县', '景县'), GeneralType('阜城县', '阜城县'), GeneralType('冀州市', '冀州市'), GeneralType('深州市', '深州市'),
  ]),
  CityAreaInfo("太原市", [
    GeneralType('不限', 'taiyuan_area_any'),
    GeneralType('小店区', '小店区'), GeneralType('迎泽区', '迎泽区'), GeneralType('杏花岭区', '杏花岭区'), GeneralType('尖草坪区', '尖草坪区'), GeneralType('万柏林区', '万柏林区'), GeneralType('晋源区', '晋源区'), GeneralType('清徐县', '清徐县'), GeneralType('阳曲县', '阳曲县'), GeneralType('娄烦县', '娄烦县'), GeneralType('古交市', '古交市'),
  ]),
  CityAreaInfo("大同市", [
    GeneralType('不限', 'datong_area_any'),
    GeneralType('城区', '城区'), GeneralType('矿区', '矿区'), GeneralType('南郊区', '南郊区'), GeneralType('新荣区', '新荣区'), GeneralType('阳高县', '阳高县'), GeneralType('天镇县', '天镇县'), GeneralType('广灵县', '广灵县'), GeneralType('灵丘县', '灵丘县'), GeneralType('浑源县', '浑源县'), GeneralType('左云县', '左云县'), GeneralType('大同县', '大同县'),
  ]),
  CityAreaInfo("阳泉市", [
    GeneralType('不限', 'yangquan_area_any'),
    GeneralType('城区', '城区'), GeneralType('矿区', '矿区'), GeneralType('郊区', '郊区'), GeneralType('平定县', '平定县'), GeneralType('盂县', '盂县'),
  ]),
  CityAreaInfo("长治市", [
    GeneralType('不限', 'changzhi_sx_area_any'),
    GeneralType('城区', '城区'), GeneralType('郊区', '郊区'), GeneralType('长治县', '长治县'), GeneralType('襄垣县', '襄垣县'), GeneralType('屯留县', '屯留县'), GeneralType('平顺县', '平顺县'), GeneralType('黎城县', '黎城县'), GeneralType('壶关县', '壶关县'), GeneralType('长子县', '长子县'), GeneralType('武乡县', '武乡县'), GeneralType('沁县', '沁县'), GeneralType('沁源县', '沁源县'), GeneralType('潞城市', '潞城市'),
  ]),
  CityAreaInfo("晋城市", [
    GeneralType('不限', 'jincheng_sx_area_any'),
    GeneralType('城区', '城区'), GeneralType('沁水县', '沁水县'), GeneralType('阳城县', '阳城县'), GeneralType('陵川县', '陵川县'), GeneralType('泽州县', '泽州县'), GeneralType('高平市', '高平市'),
  ]),
  CityAreaInfo("朔州市", [
    GeneralType('不限', 'shuozhou_area_any'),
    GeneralType('朔城区', '朔城区'), GeneralType('平鲁区', '平鲁区'), GeneralType('山阴县', '山阴县'), GeneralType('应县', '应县'), GeneralType('右玉县', '右玉县'), GeneralType('怀仁县', '怀仁县'),
  ]),
  CityAreaInfo("晋中市", [
    GeneralType('不限', 'jinzhong_sx_area_any'),
    GeneralType('榆次区', '榆次区'), GeneralType('榆社县', '榆社县'), GeneralType('左权县', '左权县'), GeneralType('和顺县', '和顺县'), GeneralType('昔阳县', '昔阳县'), GeneralType('寿阳县', '寿阳县'), GeneralType('太谷县', '太谷县'), GeneralType('祁县', '祁县'), GeneralType('平遥县', '平遥县'), GeneralType('灵石县', '灵石县'), GeneralType('介休市', '介休市'),
  ]),
  CityAreaInfo("运城市", [
    GeneralType('不限', 'yuncheng_sx_area_any'),
    GeneralType('盐湖区', '盐湖区'), GeneralType('临猗县', '临猗县'), GeneralType('万荣县', '万荣县'), GeneralType('闻喜县', '闻喜县'), GeneralType('稷山县', '稷山县'), GeneralType('新绛县', '新绛县'), GeneralType('绛县', '绛县'), GeneralType('垣曲县', '垣曲县'), GeneralType('夏县', '夏县'), GeneralType('平陆县', '平陆县'), GeneralType('芮城县', '芮城县'), GeneralType('永济市', '永济市'), GeneralType('河津市', '河津市'),
  ]),
  CityAreaInfo("忻州市", [
    GeneralType('不限', 'xinzhou_sx_area_any'),
    GeneralType('忻府区', '忻府区'), GeneralType('定襄县', '定襄县'), GeneralType('五台县', '五台县'), GeneralType('代县', '代县'), GeneralType('繁峙县', '繁峙县'), GeneralType('宁武县', '宁武县'), GeneralType('静乐县', '静乐县'), GeneralType('神池县', '神池县'), GeneralType('五寨县', '五寨县'), GeneralType('岢岚县', '岢岚县'), GeneralType('河曲县', '河曲县'), GeneralType('保德县', '保德县'), GeneralType('偏关县', '偏关县'), GeneralType('原平市', '原平市'),
  ]),
  CityAreaInfo("临汾市", [
    GeneralType('不限', 'linfen_area_any'),
    GeneralType('尧都区', '尧都区'), GeneralType('曲沃县', '曲沃县'), GeneralType('翼城县', '翼城县'), GeneralType('襄汾县', '襄汾县'), GeneralType('洪洞县', '洪洞县'), GeneralType('古县', '古县'), GeneralType('安泽县', '安泽县'), GeneralType('浮山县', '浮山县'), GeneralType('吉县', '吉县'), GeneralType('乡宁县', '乡宁县'), GeneralType('大宁县', '大宁县'), GeneralType('隰县', '隰县'), GeneralType('永和县', '永和县'), GeneralType('蒲县', '蒲县'), GeneralType('汾西县', '汾西县'), GeneralType('侯马市', '侯马市'), GeneralType('霍州市', '霍州市'),
  ]),
  CityAreaInfo("吕梁市", [
    GeneralType('不限', 'luliang_area_any'),
    GeneralType('离石区', '离石区'), GeneralType('文水县', '文水县'), GeneralType('交城县', '交城县'), GeneralType('兴县', '兴县'), GeneralType('临县', '临县'), GeneralType('柳林县', '柳林县'), GeneralType('石楼县', '石楼县'), GeneralType('岚县', '岚县'), GeneralType('方山县', '方山县'), GeneralType('中阳县', '中阳县'), GeneralType('交口县', '交口县'), GeneralType('孝义市', '孝义市'), GeneralType('汾阳市', '汾阳市'),
  ]),
  CityAreaInfo("呼和浩特市", [
    GeneralType('不限', 'hohhot_area_any'),
    GeneralType('新城区', '新城区'), GeneralType('回民区', '回民区'), GeneralType('玉泉区', '玉泉区'), GeneralType('赛罕区', '赛罕区'), GeneralType('土默特左旗', '土默特左旗'), GeneralType('托克托县', '托克托县'), GeneralType('和林格尔县', '和林格尔县'), GeneralType('清水河县', '清水河县'), GeneralType('武川县', '武川县'),
  ]),
  CityAreaInfo("包头市", [
    GeneralType('不限', 'baotou_area_any'),
    GeneralType('东河区', '东河区'), GeneralType('昆都仑区', '昆都仑区'), GeneralType('青山区', '青山区'), GeneralType('石拐区', '石拐区'), GeneralType('白云鄂博矿区', '白云鄂博矿区'), GeneralType('九原区', '九原区'), GeneralType('土默特右旗', '土默特右旗'), GeneralType('固阳县', '固阳县'), GeneralType('达尔罕茂明安联合旗', '达尔罕茂明安联合旗'),
  ]),
  CityAreaInfo("乌海市", [
    GeneralType('不限', 'wuhai_area_any'),
    GeneralType('海勃湾区', '海勃湾区'), GeneralType('海南区', '海南区'), GeneralType('乌达区', '乌达区'),
  ]),
  CityAreaInfo("赤峰市", [
    GeneralType('不限', 'chifeng_area_any'),
    GeneralType('红山区', '红山区'), GeneralType('元宝山区', '元宝山区'), GeneralType('松山区', '松山区'), GeneralType('阿鲁科尔沁旗', '阿鲁科尔沁旗'), GeneralType('巴林左旗', '巴林左旗'), GeneralType('巴林右旗', '巴林右旗'), GeneralType('林西县', '林西县'), GeneralType('克什克腾旗', '克什克腾旗'), GeneralType('翁牛特旗', '翁牛特旗'), GeneralType('喀喇沁旗', '喀喇沁旗'), GeneralType('宁城县', '宁城县'), GeneralType('敖汉旗', '敖汉旗'),
  ]),
  CityAreaInfo("通辽市", [
    GeneralType('不限', 'tongliao_area_any'),
    GeneralType('科尔沁区', '科尔沁区'), GeneralType('科尔沁左翼中旗', '科尔沁左翼中旗'), GeneralType('科尔沁左翼后旗', '科尔沁左翼后旗'), GeneralType('开鲁县', '开鲁县'), GeneralType('库伦旗', '库伦旗'), GeneralType('奈曼旗', '奈曼旗'), GeneralType('扎鲁特旗', '扎鲁特旗'), GeneralType('霍林郭勒市', '霍林郭勒市'),
  ]),
  CityAreaInfo("鄂尔多斯市", [
    GeneralType('不限', 'ordos_area_any'),
    GeneralType('东胜区', '东胜区'), GeneralType('达拉特旗', '达拉特旗'), GeneralType('准格尔旗', '准格尔旗'), GeneralType('鄂托克前旗', '鄂托克前旗'), GeneralType('鄂托克旗', '鄂托克旗'), GeneralType('杭锦旗', '杭锦旗'), GeneralType('乌审旗', '乌审旗'), GeneralType('伊金霍洛旗', '伊金霍洛旗'),
  ]),
  CityAreaInfo("呼伦贝尔市", [
    GeneralType('不限', 'hulunbuir_area_any'),
    GeneralType('海拉尔区', '海拉尔区'), GeneralType('阿荣旗', '阿荣旗'), GeneralType('莫力达瓦达斡尔族自治旗', '莫力达瓦达斡尔族自治旗'), GeneralType('鄂伦春自治旗', '鄂伦春自治旗'), GeneralType('鄂温克族自治旗', '鄂温克族自治旗'), GeneralType('陈巴尔虎旗', '陈巴尔虎旗'), GeneralType('新巴尔虎左旗', '新巴尔虎左旗'), GeneralType('新巴尔虎右旗', '新巴尔虎右旗'), GeneralType('满洲里市', '满洲里市'), GeneralType('牙克石市', '牙克石市'), GeneralType('扎兰屯市', '扎兰屯市'), GeneralType('额尔古纳市', '额尔古纳市'), GeneralType('根河市', '根河市'),
  ]),
  CityAreaInfo("巴彦淖尔市", [
    GeneralType('不限', 'bayannur_area_any'),
    GeneralType('临河区', '临河区'), GeneralType('五原县', '五原县'), GeneralType('磴口县', '磴口县'), GeneralType('乌拉特前旗', '乌拉特前旗'), GeneralType('乌拉特中旗', '乌拉特中旗'), GeneralType('乌拉特后旗', '乌拉特后旗'), GeneralType('杭锦后旗', '杭锦后旗'),
  ]),
  CityAreaInfo("乌兰察布市", [
    GeneralType('不限', 'ulanqab_area_any'),
    GeneralType('集宁区', '集宁区'), GeneralType('卓资县', '卓资县'), GeneralType('化德县', '化德县'), GeneralType('商都县', '商都县'), GeneralType('兴和县', '兴和县'), GeneralType('凉城县', '凉城县'), GeneralType('察哈尔右翼前旗', '察哈尔右翼前旗'), GeneralType('察哈尔右翼中旗', '察哈尔右翼中旗'), GeneralType('察哈尔右翼后旗', '察哈尔右翼后旗'), GeneralType('四子王旗', '四子王旗'), GeneralType('丰镇市', '丰镇市'),
  ]),
  CityAreaInfo("兴安盟", [
    GeneralType('不限', 'xingan_area_any'),
    GeneralType('乌兰浩特市', '乌兰浩特市'), GeneralType('阿尔山市', '阿尔山市'), GeneralType('科尔沁右翼前旗', '科尔沁右翼前旗'), GeneralType('科尔沁右翼中旗', '科尔沁右翼中旗'), GeneralType('扎赉特旗', '扎赉特旗'), GeneralType('突泉县', '突泉县'),
  ]),
  CityAreaInfo("锡林郭勒盟", [
    GeneralType('不限', 'xilingol_area_any'),
    GeneralType('二连浩特市', '二连浩特市'), GeneralType('锡林浩特市', '锡林浩特市'), GeneralType('阿巴嘎旗', '阿巴嘎旗'), GeneralType('苏尼特左旗', '苏尼特左旗'), GeneralType('苏尼特右旗', '苏尼特右旗'), GeneralType('东乌珠穆沁旗', '东乌珠穆沁旗'), GeneralType('西乌珠穆沁旗', '西乌珠穆沁旗'), GeneralType('太仆寺旗', '太仆寺旗'), GeneralType('镶黄旗', '镶黄旗'), GeneralType('正镶白旗', '正镶白旗'), GeneralType('正蓝旗', '正蓝旗'), GeneralType('多伦县', '多伦县'),
  ]),
  CityAreaInfo("阿拉善盟", [
    GeneralType('不限', 'alxa_area_any'),
    GeneralType('阿拉善左旗', '阿拉善左旗'), GeneralType('阿拉善右旗', '阿拉善右旗'), GeneralType('额济纳旗', '额济纳旗'),
  ]),
  CityAreaInfo("沈阳市", [
    GeneralType('不限', 'shenyang_ln_area_any'),
    GeneralType('和平区', '和平区'), GeneralType('沈河区', '沈河区'), GeneralType('大东区', '大东区'), GeneralType('皇姑区', '皇姑区'), GeneralType('铁西区', '铁西区'), GeneralType('苏家屯区', '苏家屯区'), GeneralType('东陵区', '东陵区'), GeneralType('沈北新区', '沈北新区'), GeneralType('于洪区', '于洪区'), GeneralType('辽中县', '辽中县'), GeneralType('康平县', '康平县'), GeneralType('法库县', '法库县'), GeneralType('新民市', '新民市'),
  ]),
  CityAreaInfo("大连市", [
    GeneralType('不限', 'dalian_area_any'),
    GeneralType('中山区', '中山区'), GeneralType('西岗区', '西岗区'), GeneralType('沙河口区', '沙河口区'), GeneralType('甘井子区', '甘井子区'), GeneralType('旅顺口区', '旅顺口区'), GeneralType('金州区', '金州区'), GeneralType('长海县', '长海县'), GeneralType('瓦房店市', '瓦房店市'), GeneralType('普兰店市', '普兰店市'), GeneralType('庄河市', '庄河市'),
  ]),
  CityAreaInfo("鞍山市", [
    GeneralType('不限', 'anshan_area_any'),
    GeneralType('铁东区', '铁东区'), GeneralType('铁西区', '铁西区'), GeneralType('立山区', '立山区'), GeneralType('千山区', '千山区'), GeneralType('台安县', '台安县'), GeneralType('岫岩满族自治县', '岫岩满族自治县'), GeneralType('海城市', '海城市'),
  ]),
  CityAreaInfo("抚顺市", [
    GeneralType('不限', 'fushun_area_any'),
    GeneralType('新抚区', '新抚区'), GeneralType('东洲区', '东洲区'), GeneralType('望花区', '望花区'), GeneralType('顺城区', '顺城区'), GeneralType('抚顺县', '抚顺县'), GeneralType('新宾满族自治县', '新宾满族自治县'), GeneralType('清原满族自治县', '清原满族自治县'),
  ]),
  CityAreaInfo("本溪市", [
    GeneralType('不限', 'benxi_area_any'),
    GeneralType('平山区', '平山区'), GeneralType('溪湖区', '溪湖区'), GeneralType('明山区', '明山区'), GeneralType('南芬区', '南芬区'), GeneralType('本溪满族自治县', '本溪满族自治县'), GeneralType('桓仁满族自治县', '桓仁满族自治县'),
  ]),
  CityAreaInfo("丹东市", [
    GeneralType('不限', 'dandong_area_any'),
    GeneralType('元宝区', '元宝区'), GeneralType('振兴区', '振兴区'), GeneralType('振安区', '振安区'), GeneralType('宽甸满族自治县', '宽甸满族自治县'), GeneralType('东港市', '东港市'), GeneralType('凤城市', '凤城市'),
  ]),
  CityAreaInfo("锦州市", [
    GeneralType('不限', 'jinzhou_ln_area_any'),
    GeneralType('古塔区', '古塔区'), GeneralType('凌河区', '凌河区'), GeneralType('太和区', '太和区'), GeneralType('黑山县', '黑山县'), GeneralType('义县', '义县'), GeneralType('凌海市', '凌海市'), GeneralType('北镇市', '北镇市'),
  ]),
  CityAreaInfo("营口市", [
    GeneralType('不限', 'yingkou_area_any'),
    GeneralType('站前区', '站前区'), GeneralType('西市区', '西市区'), GeneralType('鲅鱼圈区', '鲅鱼圈区'), GeneralType('老边区', '老边区'), GeneralType('盖州市', '盖州市'), GeneralType('大石桥市', '大石桥市'),
  ]),
  CityAreaInfo("阜新市", [
    GeneralType('不限', 'fuxin_area_any'),
    GeneralType('海州区', '海州区'), GeneralType('新邱区', '新邱区'), GeneralType('太平区', '太平区'), GeneralType('清河门区', '清河门区'), GeneralType('细河区', '细河区'), GeneralType('阜新蒙古族自治县', '阜新蒙古族自治县'), GeneralType('彰武县', '彰武县'),
  ]),
  CityAreaInfo("辽阳市", [
    GeneralType('不限', 'liaoyang_area_any'),
    GeneralType('白塔区', '白塔区'), GeneralType('文圣区', '文圣区'), GeneralType('宏伟区', '宏伟区'), GeneralType('弓长岭区', '弓长岭区'), GeneralType('太子河区', '太子河区'), GeneralType('辽阳县', '辽阳县'), GeneralType('灯塔市', '灯塔市'),
  ]),
  CityAreaInfo("盘锦市", [
    GeneralType('不限', 'panjin_area_any'),
    GeneralType('双台子区', '双台子区'), GeneralType('兴隆台区', '兴隆台区'), GeneralType('大洼县', '大洼县'), GeneralType('盘山县', '盘山县'),
  ]),
  CityAreaInfo("铁岭市", [
    GeneralType('不限', 'tieling_area_any'),
    GeneralType('银州区', '银州区'), GeneralType('清河区', '清河区'), GeneralType('铁岭县', '铁岭县'), GeneralType('西丰县', '西丰县'), GeneralType('昌图县', '昌图县'), GeneralType('调兵山市', '调兵山市'), GeneralType('开原市', '开原市'),
  ]),
  CityAreaInfo("朝阳市", [
    GeneralType('不限', 'chaoyang_ln_area_any'),
    GeneralType('双塔区', '双塔区'), GeneralType('龙城区', '龙城区'), GeneralType('朝阳县', '朝阳县'), GeneralType('建平县', '建平县'), GeneralType('喀喇沁左翼蒙古族自治县', '喀喇沁左翼蒙古族自治县'), GeneralType('北票市', '北票市'), GeneralType('凌源市', '凌源市'),
  ]),
  CityAreaInfo("葫芦岛市", [
    GeneralType('不限', 'huludao_area_any'),
    GeneralType('连山区', '连山区'), GeneralType('龙港区', '龙港区'), GeneralType('南票区', '南票区'), GeneralType('绥中县', '绥中县'), GeneralType('建昌县', '建昌县'), GeneralType('兴城市', '兴城市'),
  ]),
  CityAreaInfo("长春市", [
    GeneralType('不限', 'changchun_jl_area_any'),
    GeneralType('南关区', '南关区'), GeneralType('宽城区', '宽城区'), GeneralType('朝阳区', '朝阳区'), GeneralType('二道区', '二道区'), GeneralType('绿园区', '绿园区'), GeneralType('双阳区', '双阳区'), GeneralType('农安县', '农安县'), GeneralType('九台市', '九台市'), GeneralType('榆树市', '榆树市'), GeneralType('德惠市', '德惠市'),
  ]),
  CityAreaInfo("吉林市", [
    GeneralType('不限', 'jilin_jl_area_any'),
    GeneralType('昌邑区', '昌邑区'), GeneralType('龙潭区', '龙潭区'), GeneralType('船营区', '船营区'), GeneralType('丰满区', '丰满区'), GeneralType('永吉县', '永吉县'), GeneralType('蛟河市', '蛟河市'), GeneralType('桦甸市', '桦甸市'), GeneralType('舒兰市', '舒兰市'), GeneralType('磐石市', '磐石市'),
  ]),
  CityAreaInfo("四平市", [
    GeneralType('不限', 'siping_area_any'),
    GeneralType('铁西区', '铁西区'), GeneralType('铁东区', '铁东区'), GeneralType('梨树县', '梨树县'), GeneralType('伊通满族自治县', '伊通满族自治县'), GeneralType('公主岭市', '公主岭市'), GeneralType('双辽市', '双辽市'),
  ]),
  CityAreaInfo("辽源市", [
    GeneralType('不限', 'liaoyuan_jl_area_any'),
    GeneralType('龙山区', '龙山区'), GeneralType('西安区', '西安区'), GeneralType('东丰县', '东丰县'), GeneralType('东辽县', '东辽县'),
  ]),
  CityAreaInfo("通化市", [
    GeneralType('不限', 'tonghua_area_any'),
    GeneralType('东昌区', '东昌区'), GeneralType('二道江区', '二道江区'), GeneralType('通化县', '通化县'), GeneralType('辉南县', '辉南县'), GeneralType('柳河县', '柳河县'), GeneralType('梅河口市', '梅河口市'), GeneralType('集安市', '集安市'),
  ]),
  CityAreaInfo("白山市", [
    GeneralType('不限', 'baishan_area_any'),
    GeneralType('八道江区', '八道江区'), GeneralType('江源区', '江源区'), GeneralType('抚松县', '抚松县'), GeneralType('靖宇县', '靖宇县'), GeneralType('长白朝鲜族自治县', '长白朝鲜族自治县'), GeneralType('临江市', '临江市'),
  ]),
  CityAreaInfo("松原市", [
    GeneralType('不限', 'songyuan_jl_area_any'),
    GeneralType('宁江区', '宁江区'), GeneralType('前郭尔罗斯蒙古族自治县', '前郭尔罗斯蒙古族自治县'), GeneralType('长岭县', '长岭县'), GeneralType('乾安县', '乾安县'), GeneralType('扶余县', '扶余县'),
  ]),
  CityAreaInfo("白城市", [
    GeneralType('不限', 'baicheng_jl_area_any'),
    GeneralType('洮北区', '洮北区'), GeneralType('镇赉县', '镇赉县'), GeneralType('通榆县', '通榆县'), GeneralType('洮南市', '洮南市'), GeneralType('大安市', '大安市'),
  ]),
  CityAreaInfo("延边朝鲜族自治州", [
    GeneralType('不限', 'yanbian_area_any'),
    GeneralType('延吉市', '延吉市'), GeneralType('图们市', '图们市'), GeneralType('敦化市', '敦化市'), GeneralType('珲春市', '珲春市'), GeneralType('龙井市', '龙井市'), GeneralType('和龙市', '和龙市'), GeneralType('汪清县', '汪清县'), GeneralType('安图县', '安图县'),
  ]),
  CityAreaInfo("哈尔滨市", [
    GeneralType('不限', 'harbin_area_any'),
    GeneralType('道里区', '道里区'), GeneralType('南岗区', '南岗区'), GeneralType('道外区', '道外区'), GeneralType('平房区', '平房区'), GeneralType('松北区', '松北区'), GeneralType('香坊区', '香坊区'), GeneralType('呼兰区', '呼兰区'), GeneralType('阿城区', '阿城区'), GeneralType('依兰县', '依兰县'), GeneralType('方正县', '方正县'), GeneralType('宾县', '宾县'), GeneralType('巴彦县', '巴彦县'), GeneralType('木兰县', '木兰县'), GeneralType('通河县', '通河县'), GeneralType('延寿县', '延寿县'), GeneralType('双城市', '双城市'), GeneralType('尚志市', '尚志市'), GeneralType('五常市', '五常市'),
  ]),
  CityAreaInfo("齐齐哈尔市", [
    GeneralType('不限', 'qiqihar_area_any'),
    GeneralType('龙沙区', '龙沙区'), GeneralType('建华区', '建华区'), GeneralType('铁锋区', '铁锋区'), GeneralType('昂昂溪区', '昂昂溪区'), GeneralType('富拉尔基区', '富拉尔基区'), GeneralType('碾子山区', '碾子山区'), GeneralType('梅里斯达斡尔族区', '梅里斯达斡尔族区'), GeneralType('龙江县', '龙江县'), GeneralType('依安县', '依安县'), GeneralType('泰来县', '泰来县'), GeneralType('甘南县', '甘南县'), GeneralType('富裕县', '富裕县'), GeneralType('克山县', '克山县'), GeneralType('克东县', '克东县'), GeneralType('拜泉县', '拜泉县'), GeneralType('讷河市', '讷河市'),
  ]),
  CityAreaInfo("鸡西市", [
    GeneralType('不限', 'jixi_hlj_area_any'),
    GeneralType('鸡冠区', '鸡冠区'), GeneralType('恒山区', '恒山区'), GeneralType('滴道区', '滴道区'), GeneralType('梨树区', '梨树区'), GeneralType('城子河区', '城子河区'), GeneralType('麻山区', '麻山区'), GeneralType('鸡东县', '鸡东县'), GeneralType('虎林市', '虎林市'), GeneralType('密山市', '密山市'),
  ]),
  CityAreaInfo("鹤岗市", [
    GeneralType('不限', 'hegang_hlj_area_any'),
    GeneralType('向阳区', '向阳区'), GeneralType('工农区', '工农区'), GeneralType('南山区', '南山区'), GeneralType('兴安区', '兴安区'), GeneralType('东山区', '东山区'), GeneralType('兴山区', '兴山区'), GeneralType('萝北县', '萝北县'), GeneralType('绥滨县', '绥滨县'),
  ]),
  CityAreaInfo("双鸭山市", [
    GeneralType('不限', 'shuangyashan_area_any'),
    GeneralType('尖山区', '尖山区'), GeneralType('岭东区', '岭东区'), GeneralType('四方台区', '四方台区'), GeneralType('宝山区', '宝山区'), GeneralType('集贤县', '集贤县'), GeneralType('友谊县', '友谊县'), GeneralType('宝清县', '宝清县'), GeneralType('饶河县', '饶河县'),
  ]),
  CityAreaInfo("大庆市", [
    GeneralType('不限', 'daqing_area_any'),
    GeneralType('萨尔图区', '萨尔图区'), GeneralType('龙凤区', '龙凤区'), GeneralType('让胡路区', '让胡路区'), GeneralType('红岗区', '红岗区'), GeneralType('大同区', '大同区'), GeneralType('肇州县', '肇州县'), GeneralType('肇源县', '肇源县'), GeneralType('林甸县', '林甸县'), GeneralType('杜尔伯特蒙古族自治县', '杜尔伯特蒙古族自治县'),
  ]),
  CityAreaInfo("伊春市", [
    GeneralType('不限', 'yichun_hlj_area_any'),
    GeneralType('伊春区', '伊春区'), GeneralType('南岔区', '南岔区'), GeneralType('友好区', '友好区'), GeneralType('西林区', '西林区'), GeneralType('翠峦区', '翠峦区'), GeneralType('新青区', '新青区'), GeneralType('美溪区', '美溪区'), GeneralType('金山屯区', '金山屯区'), GeneralType('五营区', '五营区'), GeneralType('乌马河区', '乌马河区'), GeneralType('汤旺河区', '汤旺河区'), GeneralType('带岭区', '带岭区'), GeneralType('乌伊岭区', '乌伊岭区'), GeneralType('红星区', '红星区'), GeneralType('上甘岭区', '上甘岭区'), GeneralType('嘉荫县', '嘉荫县'), GeneralType('铁力市', '铁力市'),
  ]),
  CityAreaInfo("佳木斯市", [
    GeneralType('不限', 'jiamusi_area_any'),
    GeneralType('向阳区', '向阳区'), GeneralType('前进区', '前进区'), GeneralType('东风区', '东风区'), GeneralType('郊区', '郊区'), GeneralType('桦南县', '桦南县'), GeneralType('桦川县', '桦川县'), GeneralType('汤原县', '汤原县'), GeneralType('抚远县', '抚远县'), GeneralType('同江市', '同江市'), GeneralType('富锦市', '富锦市'),
  ]),
  CityAreaInfo("七台河市", [
    GeneralType('不限', 'qitaihe_area_any'),
    GeneralType('新兴区', '新兴区'), GeneralType('桃山区', '桃山区'), GeneralType('茄子河区', '茄子河区'), GeneralType('勃利县', '勃利县'),
  ]),
  CityAreaInfo("牡丹江市", [
    GeneralType('不限', 'mudanjiang_area_any'),
    GeneralType('东安区', '东安区'), GeneralType('阳明区', '阳明区'), GeneralType('爱民区', '爱民区'), GeneralType('西安区', '西安区'), GeneralType('东宁县', '东宁县'), GeneralType('林口县', '林口县'), GeneralType('绥芬河市', '绥芬河市'), GeneralType('海林市', '海林市'), GeneralType('宁安市', '宁安市'), GeneralType('穆棱市', '穆棱市'),
  ]),
  CityAreaInfo("黑河市", [
    GeneralType('不限', 'heihe_hlj_area_any'),
    GeneralType('爱辉区', '爱辉区'), GeneralType('嫩江县', '嫩江县'), GeneralType('逊克县', '逊克县'), GeneralType('孙吴县', '孙吴县'), GeneralType('北安市', '北安市'), GeneralType('五大连池市', '五大连池市'),
  ]),
  CityAreaInfo("绥化市", [
    GeneralType('不限', 'suihua_area_any'),
    GeneralType('北林区', '北林区'), GeneralType('望奎县', '望奎县'), GeneralType('兰西县', '兰西县'), GeneralType('青冈县', '青冈县'), GeneralType('庆安县', '庆安县'), GeneralType('明水县', '明水县'), GeneralType('绥棱县', '绥棱县'), GeneralType('安达市', '安达市'), GeneralType('肇东市', '肇东市'), GeneralType('海伦市', '海伦市'),
  ]),
  CityAreaInfo("大兴安岭地区", [
    GeneralType('不限', 'daxinganling_area_any'),
    GeneralType('加格达奇区', '加格达奇区'), GeneralType('松岭区', '松岭区'), GeneralType('新林区', '新林区'), GeneralType('呼中区', '呼中区'), GeneralType('呼玛县', '呼玛县'), GeneralType('塔河县', '塔河县'), GeneralType('漠河县', '漠河县'),
  ]),
  CityAreaInfo("上海市", [
    GeneralType('不限', 'shanghai_area_any'),
    GeneralType('黄浦区', '黄浦区'), GeneralType('卢湾区', '卢湾区'), GeneralType('徐汇区', '徐汇区'), GeneralType('长宁区', '长宁区'), GeneralType('静安区', '静安区'), GeneralType('普陀区', '普陀区'), GeneralType('闸北区', '闸北区'), GeneralType('虹口区', '虹口区'), GeneralType('杨浦区', '杨浦区'), GeneralType('闵行区', '闵行区'), GeneralType('宝山区', '宝山区'), GeneralType('嘉定区', '嘉定区'), GeneralType('浦东新区', '浦东新区'), GeneralType('金山区', '金山区'), GeneralType('松江区', '松江区'), GeneralType('青浦区', '青浦区'), GeneralType('奉贤区', '奉贤区'), GeneralType('崇明县', '崇明县'),
  ]),
  CityAreaInfo("南京市", [
    GeneralType('不限', 'nanjing_area_any'),
    GeneralType('玄武区', '玄武区'), GeneralType('白下区', '白下区'), GeneralType('秦淮区', '秦淮区'), GeneralType('建邺区', '建邺区'), GeneralType('鼓楼区', '鼓楼区'), GeneralType('下关区', '下关区'), GeneralType('浦口区', '浦口区'), GeneralType('栖霞区', '栖霞区'), GeneralType('雨花台区', '雨花台区'), GeneralType('江宁区', '江宁区'), GeneralType('六合区', '六合区'), GeneralType('溧水县', '溧水县'), GeneralType('高淳县', '高淳县'),
  ]),
  CityAreaInfo("无锡市", [
    GeneralType('不限', 'wuxi_area_any'),
    GeneralType('崇安区', '崇安区'), GeneralType('南长区', '南长区'), GeneralType('北塘区', '北塘区'), GeneralType('锡山区', '锡山区'), GeneralType('惠山区', '惠山区'), GeneralType('滨湖区', '滨湖区'), GeneralType('江阴市', '江阴市'), GeneralType('宜兴市', '宜兴市'),
  ]),
  CityAreaInfo("徐州市", [
    GeneralType('不限', 'xuzhou_js_area_any'),
    GeneralType('鼓楼区', '鼓楼区'), GeneralType('云龙区', '云龙区'), GeneralType('贾汪区', '贾汪区'), GeneralType('泉山区', '泉山区'), GeneralType('铜山区', '铜山区'), GeneralType('丰县', '丰县'), GeneralType('沛县', '沛县'), GeneralType('睢宁县', '睢宁县'), GeneralType('新沂市', '新沂市'), GeneralType('邳州市', '邳州市'),
  ]),
  CityAreaInfo("常州市", [
    GeneralType('不限', 'changzhou_js_area_any'),
    GeneralType('天宁区', '天宁区'), GeneralType('钟楼区', '钟楼区'), GeneralType('戚墅堰区', '戚墅堰区'), GeneralType('新北区', '新北区'), GeneralType('武进区', '武进区'), GeneralType('溧阳市', '溧阳市'), GeneralType('金坛市', '金坛市'),
  ]),
  CityAreaInfo("苏州市", [
    GeneralType('不限', 'suzhou_js_area_any'),
    GeneralType('沧浪区', '沧浪区'), GeneralType('平江区', '平江区'), GeneralType('金阊区', '金阊区'), GeneralType('虎丘区', '虎丘区'), GeneralType('吴中区', '吴中区'), GeneralType('相城区', '相城区'), GeneralType('常熟市', '常熟市'), GeneralType('张家港市', '张家港市'), GeneralType('昆山市', '昆山市'), GeneralType('吴江市', '吴江市'), GeneralType('太仓市', '太仓市'),
  ]),
  CityAreaInfo("南通市", [
    GeneralType('不限', 'nantong_area_any'),
    GeneralType('崇川区', '崇川区'), GeneralType('港闸区', '港闸区'), GeneralType('通州区', '通州区'), GeneralType('海安县', '海安县'), GeneralType('如东县', '如东县'), GeneralType('启东市', '启东市'), GeneralType('如皋市', '如皋市'), GeneralType('海门市', '海门市'),
  ]),
  CityAreaInfo("连云港市", [
    GeneralType('不限', 'lianyungang_area_any'),
    GeneralType('连云区', '连云区'), GeneralType('新浦区', '新浦区'), GeneralType('海州区', '海州区'), GeneralType('赣榆县', '赣榆县'), GeneralType('东海县', '东海县'), GeneralType('灌云县', '灌云县'), GeneralType('灌南县', '灌南县'),
  ]),
  CityAreaInfo("淮安市", [
    GeneralType('不限', 'huaian_area_any'),
    GeneralType('清河区', '清河区'), GeneralType('楚州区', '楚州区'), GeneralType('淮阴区', '淮阴区'), GeneralType('清浦区', '清浦区'), GeneralType('涟水县', '涟水县'), GeneralType('洪泽县', '洪泽县'), GeneralType('盱眙县', '盱眙县'), GeneralType('金湖县', '金湖县'),
  ]),
  CityAreaInfo("盐城市", [
    GeneralType('不限', 'yancheng_js_area_any'),
    GeneralType('亭湖区', '亭湖区'), GeneralType('盐都区', '盐都区'), GeneralType('响水县', '响水县'), GeneralType('滨海县', '滨海县'), GeneralType('阜宁县', '阜宁县'), GeneralType('射阳县', '射阳县'), GeneralType('建湖县', '建湖县'), GeneralType('东台市', '东台市'), GeneralType('大丰市', '大丰市'),
  ]),
  CityAreaInfo("扬州市", [
    GeneralType('不限', 'yangzhou_js_area_any'),
    GeneralType('广陵区', '广陵区'), GeneralType('邗江区', '邗江区'), GeneralType('维扬区', '维扬区'), GeneralType('宝应县', '宝应县'), GeneralType('仪征市', '仪征市'), GeneralType('高邮市', '高邮市'), GeneralType('江都市', '江都市'),
  ]),
  CityAreaInfo("镇江市", [
    GeneralType('不限', 'zhenjiang_area_any'),
    GeneralType('京口区', '京口区'), GeneralType('润州区', '润州区'), GeneralType('丹徒区', '丹徒区'), GeneralType('丹阳市', '丹阳市'), GeneralType('扬中市', '扬中市'), GeneralType('句容市', '句容市'),
  ]),
  CityAreaInfo("泰州市", [
    GeneralType('不限', 'taizhou_js_area_any'),
    GeneralType('海陵区', '海陵区'), GeneralType('高港区', '高港区'), GeneralType('兴化市', '兴化市'), GeneralType('靖江市', '靖江市'), GeneralType('泰兴市', '泰兴市'), GeneralType('姜堰市', '姜堰市'),
  ]),
  CityAreaInfo("宿迁市", [
    GeneralType('不限', 'suqian_area_any'),
    GeneralType('宿城区', '宿城区'), GeneralType('宿豫区', '宿豫区'), GeneralType('沭阳县', '沭阳县'), GeneralType('泗阳县', '泗阳县'), GeneralType('泗洪县', '泗洪县'),
  ]),
  CityAreaInfo("杭州市", [
    GeneralType('不限', 'hangzhou_area_any'),
    GeneralType('上城区', '上城区'), GeneralType('下城区', '下城区'), GeneralType('江干区', '江干区'), GeneralType('拱墅区', '拱墅区'), GeneralType('西湖区', '西湖区'), GeneralType('滨江区', '滨江区'), GeneralType('萧山区', '萧山区'), GeneralType('余杭区', '余杭区'), GeneralType('桐庐县', '桐庐县'), GeneralType('淳安县', '淳安县'), GeneralType('建德市', '建德市'), GeneralType('富阳市', '富阳市'), GeneralType('临安市', '临安市'),
  ]),
  CityAreaInfo("宁波市", [
    GeneralType('不限', 'ningbo_area_any'),
    GeneralType('海曙区', '海曙区'), GeneralType('江东区', '江东区'), GeneralType('江北区', '江北区'), GeneralType('北仑区', '北仑区'), GeneralType('镇海区', '镇海区'), GeneralType('鄞州区', '鄞州区'), GeneralType('象山县', '象山县'), GeneralType('宁海县', '宁海县'), GeneralType('余姚市', '余姚市'), GeneralType('慈溪市', '慈溪市'), GeneralType('奉化市', '奉化市'),
  ]),
  CityAreaInfo("温州市", [
    GeneralType('不限', 'wenzhou_area_any'),
    GeneralType('鹿城区', '鹿城区'), GeneralType('龙湾区', '龙湾区'), GeneralType('瓯海区', '瓯海区'), GeneralType('洞头县', '洞头县'), GeneralType('永嘉县', '永嘉县'), GeneralType('平阳县', '平阳县'), GeneralType('苍南县', '苍南县'), GeneralType('文成县', '文成县'), GeneralType('泰顺县', '泰顺县'), GeneralType('瑞安市', '瑞安市'), GeneralType('乐清市', '乐清市'),
  ]),
  CityAreaInfo("嘉兴市", [
    GeneralType('不限', 'jiaxing_zj_area_any'),
    GeneralType('南湖区', '南湖区'), GeneralType('秀洲区', '秀洲区'), GeneralType('嘉善县', '嘉善县'), GeneralType('海盐县', '海盐县'), GeneralType('海宁市', '海宁市'), GeneralType('平湖市', '平湖市'), GeneralType('桐乡市', '桐乡市'),
  ]),
  CityAreaInfo("湖州市", [
    GeneralType('不限', 'huzhou_zj_area_any'),
    GeneralType('吴兴区', '吴兴区'), GeneralType('南浔区', '南浔区'), GeneralType('德清县', '德清县'), GeneralType('长兴县', '长兴县'), GeneralType('安吉县', '安吉县'),
  ]),
  CityAreaInfo("绍兴市", [
    GeneralType('不限', 'shaoxing_area_any'),
    GeneralType('越城区', '越城区'), GeneralType('绍兴县', '绍兴县'), GeneralType('新昌县', '新昌县'), GeneralType('诸暨市', '诸暨市'), GeneralType('上虞市', '上虞市'), GeneralType('嵊州市', '嵊州市'),
  ]),
  CityAreaInfo("金华市", [
    GeneralType('不限', 'jinhua_area_any'),
    GeneralType('婺城区', '婺城区'), GeneralType('金东区', '金东区'), GeneralType('武义县', '武义县'), GeneralType('浦江县', '浦江县'), GeneralType('磐安县', '磐安县'), GeneralType('兰溪市', '兰溪市'), GeneralType('义乌市', '义乌市'), GeneralType('东阳市', '东阳市'), GeneralType('永康市', '永康市'),
  ]),
  CityAreaInfo("衢州市", [
    GeneralType('不限', 'quzhou_zj_area_any'),
    GeneralType('柯城区', '柯城区'), GeneralType('衢江区', '衢江区'), GeneralType('常山县', '常山县'), GeneralType('开化县', '开化县'), GeneralType('龙游县', '龙游县'), GeneralType('江山市', '江山市'),
  ]),
  CityAreaInfo("舟山市", [
    GeneralType('不限', 'zhoushan_area_any'),
    GeneralType('定海区', '定海区'), GeneralType('普陀区', '普陀区'), GeneralType('岱山县', '岱山县'), GeneralType('嵊泗县', '嵊泗县'),
  ]),
  CityAreaInfo("台州市", [
    GeneralType('不限', 'taizhou_zj_area_any'),
    GeneralType('椒江区', '椒江区'), GeneralType('黄岩区', '黄岩区'), GeneralType('路桥区', '路桥区'), GeneralType('玉环县', '玉环县'), GeneralType('三门县', '三门县'), GeneralType('天台县', '天台县'), GeneralType('仙居县', '仙居县'), GeneralType('温岭市', '温岭市'), GeneralType('临海市', '临海市'),
  ]),
  CityAreaInfo("丽水市", [
    GeneralType('不限', 'lishui_area_any'),
    GeneralType('莲都区', '莲都区'), GeneralType('青田县', '青田县'), GeneralType('缙云县', '缙云县'), GeneralType('遂昌县', '遂昌县'), GeneralType('松阳县', '松阳县'), GeneralType('云和县', '云和县'), GeneralType('庆元县', '庆元县'), GeneralType('景宁畲族自治县', '景宁畲族自治县'), GeneralType('龙泉市', '龙泉市'),
  ]),
  CityAreaInfo("合肥市", [
    GeneralType('不限', 'hefei_area_any'),
    GeneralType('瑶海区', '瑶海区'), GeneralType('庐阳区', '庐阳区'), GeneralType('蜀山区', '蜀山区'), GeneralType('包河区', '包河区'), GeneralType('长丰县', '长丰县'), GeneralType('肥东县', '肥东县'), GeneralType('肥西县', '肥西县'),
  ]),
  CityAreaInfo("芜湖市", [
    GeneralType('不限', 'wuhu_area_any'),
    GeneralType('镜湖区', '镜湖区'), GeneralType('弋江区', '弋江区'), GeneralType('鸠江区', '鸠江区'), GeneralType('三山区', '三山区'), GeneralType('芜湖县', '芜湖县'), GeneralType('繁昌县', '繁昌县'), GeneralType('南陵县', '南陵县'),
  ]),
  CityAreaInfo("蚌埠市", [
    GeneralType('不限', 'bengbu_area_any'),
    GeneralType('龙子湖区', '龙子湖区'), GeneralType('蚌山区', '蚌山区'), GeneralType('禹会区', '禹会区'), GeneralType('淮上区', '淮上区'), GeneralType('怀远县', '怀远县'), GeneralType('五河县', '五河县'), GeneralType('固镇县', '固镇县'),
  ]),
  CityAreaInfo("淮南市", [
    GeneralType('不限', 'huainan_area_any'),
    GeneralType('大通区', '大通区'), GeneralType('田家庵区', '田家庵区'), GeneralType('谢家集区', '谢家集区'), GeneralType('八公山区', '八公山区'), GeneralType('潘集区', '潘集区'), GeneralType('凤台县', '凤台县'),
  ]),
  CityAreaInfo("马鞍山市", [
    GeneralType('不限', 'maanshan_area_any'),
    GeneralType('金家庄区', '金家庄区'), GeneralType('花山区', '花山区'), GeneralType('雨山区', '雨山区'), GeneralType('当涂县', '当涂县'),
  ]),
  CityAreaInfo("淮北市", [
    GeneralType('不限', 'huaibei_ah_area_any'),
    GeneralType('杜集区', '杜集区'), GeneralType('相山区', '相山区'), GeneralType('烈山区', '烈山区'), GeneralType('濉溪县', '濉溪县'),
  ]),
  CityAreaInfo("铜陵市", [
    GeneralType('不限', 'tongling_area_any'),
    GeneralType('铜官山区', '铜官山区'), GeneralType('狮子山区', '狮子山区'), GeneralType('郊区', '郊区'), GeneralType('铜陵县', '铜陵县'),
  ]),
  CityAreaInfo("安庆市", [
    GeneralType('不限', 'anqing_area_any'),
    GeneralType('迎江区', '迎江区'), GeneralType('大观区', '大观区'), GeneralType('宜秀区', '宜秀区'), GeneralType('怀宁县', '怀宁县'), GeneralType('枞阳县', '枞阳县'), GeneralType('潜山县', '潜山县'), GeneralType('太湖县', '太湖县'), GeneralType('宿松县', '宿松县'), GeneralType('望江县', '望江县'), GeneralType('岳西县', '岳西县'), GeneralType('桐城市', '桐城市'),
  ]),
  CityAreaInfo("黄山市", [
    GeneralType('不限', 'huangshan_area_any'),
    GeneralType('屯溪区', '屯溪区'), GeneralType('黄山区', '黄山区'), GeneralType('徽州区', '徽州区'), GeneralType('歙县', '歙县'), GeneralType('休宁县', '休宁县'), GeneralType('黟县', '黟县'), GeneralType('祁门县', '祁门县'),
  ]),
  CityAreaInfo("滁州市", [
    GeneralType('不限', 'chuzhou_ah_area_any'),
    GeneralType('琅琊区', '琅琊区'), GeneralType('南谯区', '南谯区'), GeneralType('来安县', '来安县'), GeneralType('全椒县', '全椒县'), GeneralType('定远县', '定远县'), GeneralType('凤阳县', '凤阳县'), GeneralType('天长市', '天长市'), GeneralType('明光市', '明光市'),
  ]),
  CityAreaInfo("阜阳市", [
    GeneralType('不限', 'fuyang_ah_area_any'),
    GeneralType('颍州区', '颍州区'), GeneralType('颍东区', '颍东区'), GeneralType('颍泉区', '颍泉区'), GeneralType('临泉县', '临泉县'), GeneralType('太和县', '太和县'), GeneralType('阜南县', '阜南县'), GeneralType('颍上县', '颍上县'), GeneralType('界首市', '界首市'),
  ]),
  CityAreaInfo("宿州市", [
    GeneralType('不限', 'suzhou_ah_area_any'),
    GeneralType('埇桥区', '埇桥区'), GeneralType('砀山县', '砀山县'), GeneralType('萧县', '萧县'), GeneralType('灵璧县', '灵璧县'), GeneralType('泗县', '泗县'),
  ]),
  CityAreaInfo("巢湖市", [
    GeneralType('不限', 'chaohu_ah_area_any'),
    GeneralType('居巢区', '居巢区'), GeneralType('庐江县', '庐江县'), GeneralType('无为县', '无为县'), GeneralType('含山县', '含山县'), GeneralType('和县', '和县'),
  ]),
  CityAreaInfo("六安市", [
    GeneralType('不限', 'luan_area_any'),
    GeneralType('金安区', '金安区'), GeneralType('裕安区', '裕安区'), GeneralType('寿县', '寿县'), GeneralType('霍邱县', '霍邱县'), GeneralType('舒城县', '舒城县'), GeneralType('金寨县', '金寨县'), GeneralType('霍山县', '霍山县'),
  ]),
  CityAreaInfo("亳州市", [
    GeneralType('不限', 'bozhou_area_any'),
    GeneralType('谯城区', '谯城区'), GeneralType('涡阳县', '涡阳县'), GeneralType('蒙城县', '蒙城县'), GeneralType('利辛县', '利辛县'),
  ]),
  CityAreaInfo("池州市", [
    GeneralType('不限', 'chizhou_area_any'),
    GeneralType('贵池区', '贵池区'), GeneralType('东至县', '东至县'), GeneralType('石台县', '石台县'), GeneralType('青阳县', '青阳县'),
  ]),
  CityAreaInfo("宣城市", [
    GeneralType('不限', 'xuancheng_area_any'),
    GeneralType('宣州区', '宣州区'), GeneralType('郎溪县', '郎溪县'), GeneralType('广德县', '广德县'), GeneralType('泾县', '泾县'), GeneralType('绩溪县', '绩溪县'), GeneralType('旌德县', '旌德县'), GeneralType('宁国市', '宁国市'),
  ]),
  CityAreaInfo("福州市", [
    GeneralType('不限', 'fuzhou_fj_area_any'),
    GeneralType('鼓楼区', '鼓楼区'), GeneralType('台江区', '台江区'), GeneralType('仓山区', '仓山区'), GeneralType('马尾区', '马尾区'), GeneralType('晋安区', '晋安区'), GeneralType('闽侯县', '闽侯县'), GeneralType('连江县', '连江县'), GeneralType('罗源县', '罗源县'), GeneralType('闽清县', '闽清县'), GeneralType('永泰县', '永泰县'), GeneralType('平潭县', '平潭县'), GeneralType('福清市', '福清市'), GeneralType('长乐市', '长乐市'),
  ]),
  CityAreaInfo("厦门市", [
    GeneralType('不限', 'xiamen_area_any'),
    GeneralType('思明区', '思明区'), GeneralType('海沧区', '海沧区'), GeneralType('湖里区', '湖里区'), GeneralType('集美区', '集美区'), GeneralType('同安区', '同安区'), GeneralType('翔安区', '翔安区'),
  ]),
  CityAreaInfo("莆田市", [
    GeneralType('不限', 'putian_area_any'),
    GeneralType('城厢区', '城厢区'), GeneralType('涵江区', '涵江区'), GeneralType('荔城区', '荔城区'), GeneralType('秀屿区', '秀屿区'), GeneralType('仙游县', '仙游县'),
  ]),
  CityAreaInfo("三明市", [
    GeneralType('不限', 'sanming_area_any'),
    GeneralType('梅列区', '梅列区'), GeneralType('三元区', '三元区'), GeneralType('明溪县', '明溪县'), GeneralType('清流县', '清流县'), GeneralType('宁化县', '宁化县'), GeneralType('大田县', '大田县'), GeneralType('尤溪县', '尤溪县'), GeneralType('沙县', '沙县'), GeneralType('将乐县', '将乐县'), GeneralType('泰宁县', '泰宁县'), GeneralType('建宁县', '建宁县'), GeneralType('永安市', '永安市'),
  ]),
  CityAreaInfo("泉州市", [
    GeneralType('不限', 'quanzhou_fj_area_any'),
    GeneralType('鲤城区', '鲤城区'), GeneralType('丰泽区', '丰泽区'), GeneralType('洛江区', '洛江区'), GeneralType('泉港区', '泉港区'), GeneralType('惠安县', '惠安县'), GeneralType('安溪县', '安溪县'), GeneralType('永春县', '永春县'), GeneralType('德化县', '德化县'), GeneralType('金门县', '金门县'), GeneralType('石狮市', '石狮市'), GeneralType('晋江市', '晋江市'), GeneralType('南安市', '南安市'),
  ]),
  CityAreaInfo("漳州市", [
    GeneralType('不限', 'zhangzhou_fj_area_any'),
    GeneralType('芗城区', '芗城区'), GeneralType('龙文区', '龙文区'), GeneralType('云霄县', '云霄县'), GeneralType('漳浦县', '漳浦县'), GeneralType('诏安县', '诏安县'), GeneralType('长泰县', '长泰县'), GeneralType('东山县', '东山县'), GeneralType('南靖县', '南靖县'), GeneralType('平和县', '平和县'), GeneralType('华安县', '华安县'), GeneralType('龙海市', '龙海市'),
  ]),
  CityAreaInfo("南平市", [
    GeneralType('不限', 'nanping_area_any'),
    GeneralType('延平区', '延平区'), GeneralType('顺昌县', '顺昌县'), GeneralType('浦城县', '浦城县'), GeneralType('光泽县', '光泽县'), GeneralType('松溪县', '松溪县'), GeneralType('政和县', '政和县'), GeneralType('邵武市', '邵武市'), GeneralType('武夷山市', '武夷山市'), GeneralType('建瓯市', '建瓯市'), GeneralType('建阳市', '建阳市'),
  ]),
  CityAreaInfo("龙岩市", [
    GeneralType('不限', 'longyan_area_any'),
    GeneralType('新罗区', '新罗区'), GeneralType('长汀县', '长汀县'), GeneralType('永定县', '永定县'), GeneralType('上杭县', '上杭县'), GeneralType('武平县', '武平县'), GeneralType('连城县', '连城县'), GeneralType('漳平市', '漳平市'),
  ]),
  CityAreaInfo("宁德市", [
    GeneralType('不限', 'ningde_area_any'),
    GeneralType('蕉城区', '蕉城区'), GeneralType('霞浦县', '霞浦县'), GeneralType('古田县', '古田县'), GeneralType('屏南县', '屏南县'), GeneralType('寿宁县', '寿宁县'), GeneralType('周宁县', '周宁县'), GeneralType('柘荣县', '柘荣县'), GeneralType('福安市', '福安市'), GeneralType('福鼎市', '福鼎市'),
  ]),
  CityAreaInfo("南昌市", [
    GeneralType('不限', 'nanchang_area_any'),
    GeneralType('东湖区', '东湖区'), GeneralType('西湖区', '西湖区'), GeneralType('青云谱区', '青云谱区'), GeneralType('湾里区', '湾里区'), GeneralType('青山湖区', '青山湖区'), GeneralType('南昌县', '南昌县'), GeneralType('新建县', '新建县'), GeneralType('安义县', '安义县'), GeneralType('进贤县', '进贤县'),
  ]),
  CityAreaInfo("景德镇市", [
    GeneralType('不限', 'jingdezhen_area_any'),
    GeneralType('昌江区', '昌江区'), GeneralType('珠山区', '珠山区'), GeneralType('浮梁县', '浮梁县'), GeneralType('乐平市', '乐平市'),
  ]),
  CityAreaInfo("萍乡市", [
    GeneralType('不限', 'pingxiang_area_any'),
    GeneralType('安源区', '安源区'), GeneralType('湘东区', '湘东区'), GeneralType('莲花县', '莲花县'), GeneralType('上栗县', '上栗县'), GeneralType('芦溪县', '芦溪县'),
  ]),
  CityAreaInfo("九江市", [
    GeneralType('不限', 'jiujiang_area_any'),
    GeneralType('庐山区', '庐山区'), GeneralType('浔阳区', '浔阳区'), GeneralType('九江县', '九江县'), GeneralType('武宁县', '武宁县'), GeneralType('修水县', '修水县'), GeneralType('永修县', '永修县'), GeneralType('德安县', '德安县'), GeneralType('星子县', '星子县'), GeneralType('都昌县', '都昌县'), GeneralType('湖口县', '湖口县'), GeneralType('彭泽县', '彭泽县'), GeneralType('瑞昌市', '瑞昌市'), GeneralType('共青城市', '共青城市'),
  ]),
  CityAreaInfo("新余市", [
    GeneralType('不限', 'xinyu_area_any'),
    GeneralType('渝水区', '渝水区'), GeneralType('分宜县', '分宜县'),
  ]),
  CityAreaInfo("鹰潭市", [
    GeneralType('不限', 'yingtan_area_any'),
    GeneralType('月湖区', '月湖区'), GeneralType('余江县', '余江县'), GeneralType('贵溪市', '贵溪市'),
  ]),
  CityAreaInfo("赣州市", [
    GeneralType('不限', 'ganzhou_area_any'),
    GeneralType('章贡区', '章贡区'), GeneralType('赣县', '赣县'), GeneralType('信丰县', '信丰县'), GeneralType('大余县', '大余县'), GeneralType('上犹县', '上犹县'), GeneralType('崇义县', '崇义县'), GeneralType('安远县', '安远县'), GeneralType('龙南县', '龙南县'), GeneralType('定南县', '定南县'), GeneralType('全南县', '全南县'), GeneralType('宁都县', '宁都县'), GeneralType('于都县', '于都县'), GeneralType('兴国县', '兴国县'), GeneralType('会昌县', '会昌县'), GeneralType('寻乌县', '寻乌县'), GeneralType('石城县', '石城县'), GeneralType('瑞金市', '瑞金市'), GeneralType('南康市', '南康市'),
  ]),
  CityAreaInfo("吉安市", [
    GeneralType('不限', 'jian_area_any'),
    GeneralType('吉州区', '吉州区'), GeneralType('青原区', '青原区'), GeneralType('吉安县', '吉安县'), GeneralType('吉水县', '吉水县'), GeneralType('峡江县', '峡江县'), GeneralType('新干县', '新干县'), GeneralType('永丰县', '永丰县'), GeneralType('泰和县', '泰和县'), GeneralType('遂川县', '遂川县'), GeneralType('万安县', '万安县'), GeneralType('安福县', '安福县'), GeneralType('永新县', '永新县'), GeneralType('井冈山市', '井冈山市'),
  ]),
  CityAreaInfo("宜春市", [
    GeneralType('不限', 'yichun_jx_area_any'),
    GeneralType('袁州区', '袁州区'), GeneralType('奉新县', '奉新县'), GeneralType('万载县', '万载县'), GeneralType('上高县', '上高县'), GeneralType('宜丰县', '宜丰县'), GeneralType('靖安县', '靖安县'), GeneralType('铜鼓县', '铜鼓县'), GeneralType('丰城市', '丰城市'), GeneralType('樟树市', '樟树市'), GeneralType('高安市', '高安市'),
  ]),
  CityAreaInfo("抚州市", [
    GeneralType('不限', 'fuzhou_jx_area_any'),
    GeneralType('临川区', '临川区'), GeneralType('南城县', '南城县'), GeneralType('黎川县', '黎川县'), GeneralType('南丰县', '南丰县'), GeneralType('崇仁县', '崇仁县'), GeneralType('乐安县', '乐安县'), GeneralType('宜黄县', '宜黄县'), GeneralType('金溪县', '金溪县'), GeneralType('资溪县', '资溪县'), GeneralType('东乡县', '东乡县'), GeneralType('广昌县', '广昌县'),
  ]),
  CityAreaInfo("上饶市", [
    GeneralType('不限', 'shangrao_area_any'),
    GeneralType('信州区', '信州区'), GeneralType('上饶县', '上饶县'), GeneralType('广丰县', '广丰县'), GeneralType('玉山县', '玉山县'), GeneralType('铅山县', '铅山县'), GeneralType('横峰县', '横峰县'), GeneralType('弋阳县', '弋阳县'), GeneralType('余干县', '余干县'), GeneralType('鄱阳县', '鄱阳县'), GeneralType('万年县', '万年县'), GeneralType('婺源县', '婺源县'), GeneralType('德兴市', '德兴市'),
  ]),
  CityAreaInfo("济南市", [
    GeneralType('不限', 'jinan_area_any'),
    GeneralType('历下区', '历下区'), GeneralType('市中区', '市中区'), GeneralType('槐荫区', '槐荫区'), GeneralType('天桥区', '天桥区'), GeneralType('历城区', '历城区'), GeneralType('长清区', '长清区'), GeneralType('平阴县', '平阴县'), GeneralType('济阳县', '济阳县'), GeneralType('商河县', '商河县'), GeneralType('章丘市', '章丘市'),
  ]),
  CityAreaInfo("青岛市", [
    GeneralType('不限', 'qingdao_area_any'),
    GeneralType('市南区', '市南区'), GeneralType('市北区', '市北区'), GeneralType('四方区', '四方区'), GeneralType('黄岛区', '黄岛区'), GeneralType('崂山区', '崂山区'), GeneralType('李沧区', '李沧区'), GeneralType('城阳区', '城阳区'), GeneralType('胶州市', '胶州市'), GeneralType('即墨市', '即墨市'), GeneralType('平度市', '平度市'), GeneralType('胶南市', '胶南市'), GeneralType('莱西市', '莱西市'),
  ]),
  CityAreaInfo("淄博市", [
    GeneralType('不限', 'zibo_area_any'),
    GeneralType('淄川区', '淄川区'), GeneralType('张店区', '张店区'), GeneralType('博山区', '博山区'), GeneralType('临淄区', '临淄区'), GeneralType('周村区', '周村区'), GeneralType('桓台县', '桓台县'), GeneralType('高青县', '高青县'), GeneralType('沂源县', '沂源县'),
  ]),
  CityAreaInfo("枣庄市", [
    GeneralType('不限', 'zaozhuang_area_any'),
    GeneralType('市中区', '市中区'), GeneralType('薛城区', '薛城区'), GeneralType('峄城区', '峄城区'), GeneralType('台儿庄区', '台儿庄区'), GeneralType('山亭区', '山亭区'), GeneralType('滕州市', '滕州市'),
  ]),
  CityAreaInfo("东营市", [
    GeneralType('不限', 'dongying_area_any'),
    GeneralType('东营区', '东营区'), GeneralType('河口区', '河口区'), GeneralType('垦利县', '垦利县'), GeneralType('利津县', '利津县'), GeneralType('广饶县', '广饶县'),
  ]),
  CityAreaInfo("烟台市", [
    GeneralType('不限', 'yantai_area_any'),
    GeneralType('芝罘区', '芝罘区'), GeneralType('福山区', '福山区'), GeneralType('牟平区', '牟平区'), GeneralType('莱山区', '莱山区'), GeneralType('长岛县', '长岛县'), GeneralType('龙口市', '龙口市'), GeneralType('莱阳市', '莱阳市'), GeneralType('莱州市', '莱州市'), GeneralType('蓬莱市', '蓬莱市'), GeneralType('招远市', '招远市'), GeneralType('栖霞市', '栖霞市'), GeneralType('海阳市', '海阳市'),
  ]),
  CityAreaInfo("潍坊市", [
    GeneralType('不限', 'weifang_area_any'),
    GeneralType('潍城区', '潍城区'), GeneralType('寒亭区', '寒亭区'), GeneralType('坊子区', '坊子区'), GeneralType('奎文区', '奎文区'), GeneralType('临朐县', '临朐县'), GeneralType('昌乐县', '昌乐县'), GeneralType('青州市', '青州市'), GeneralType('诸城市', '诸城市'), GeneralType('寿光市', '寿光市'), GeneralType('安丘市', '安丘市'), GeneralType('高密市', '高密市'), GeneralType('昌邑市', '昌邑市'),
  ]),
  CityAreaInfo("济宁市", [
    GeneralType('不限', 'jining_area_any'),
    GeneralType('市中区', '市中区'), GeneralType('任城区', '任城区'), GeneralType('微山县', '微山县'), GeneralType('鱼台县', '鱼台县'), GeneralType('金乡县', '金乡县'), GeneralType('嘉祥县', '嘉祥县'), GeneralType('汶上县', '汶上县'), GeneralType('泗水县', '泗水县'), GeneralType('梁山县', '梁山县'), GeneralType('曲阜市', '曲阜市'), GeneralType('兖州市', '兖州市'), GeneralType('邹城市', '邹城市'),
  ]),
  CityAreaInfo("泰安市", [
    GeneralType('不限', 'taian_area_any'),
    GeneralType('泰山区', '泰山区'), GeneralType('岱岳区', '岱岳区'), GeneralType('宁阳县', '宁阳县'), GeneralType('东平县', '东平县'), GeneralType('新泰市', '新泰市'), GeneralType('肥城市', '肥城市'),
  ]),
  CityAreaInfo("威海市", [
    GeneralType('不限', 'weihai_area_any'),
    GeneralType('环翠区', '环翠区'), GeneralType('文登市', '文登市'), GeneralType('荣成市', '荣成市'), GeneralType('乳山市', '乳山市'),
  ]),
  CityAreaInfo("日照市", [
    GeneralType('不限', 'rizhao_area_any'),
    GeneralType('东港区', '东港区'), GeneralType('岚山区', '岚山区'), GeneralType('五莲县', '五莲县'), GeneralType('莒县', '莒县'),
  ]),
  CityAreaInfo("莱芜市", [
    GeneralType('不限', 'laiwu_area_any'),
    GeneralType('莱城区', '莱城区'), GeneralType('钢城区', '钢城区'),
  ]),
  CityAreaInfo("临沂市", [
    GeneralType('不限', 'linyi_area_any'),
    GeneralType('兰山区', '兰山区'), GeneralType('罗庄区', '罗庄区'), GeneralType('河东区', '河东区'), GeneralType('沂南县', '沂南县'), GeneralType('郯城县', '郯城县'), GeneralType('沂水县', '沂水县'), GeneralType('苍山县', '苍山县'), GeneralType('费县', '费县'), GeneralType('平邑县', '平邑县'), GeneralType('莒南县', '莒南县'), GeneralType('蒙阴县', '蒙阴县'), GeneralType('临沭县', '临沭县'),
  ]),
  CityAreaInfo("德州市", [
    GeneralType('不限', 'dezhou_area_any'),
    GeneralType('德城区', '德城区'), GeneralType('陵县', '陵县'), GeneralType('宁津县', '宁津县'), GeneralType('庆云县', '庆云县'), GeneralType('临邑县', '临邑县'), GeneralType('齐河县', '齐河县'), GeneralType('平原县', '平原县'), GeneralType('夏津县', '夏津县'), GeneralType('武城县', '武城县'), GeneralType('乐陵市', '乐陵市'), GeneralType('禹城市', '禹城市'),
  ]),
  CityAreaInfo("聊城市", [
    GeneralType('不限', 'liaocheng_sd_area_any'),
    GeneralType('东昌府区', '东昌府区'), GeneralType('阳谷县', '阳谷县'), GeneralType('莘县', '莘县'), GeneralType('茌平县', '茌平县'), GeneralType('东阿县', '东阿县'), GeneralType('冠县', '冠县'), GeneralType('高唐县', '高唐县'), GeneralType('临清市', '临清市'),
  ]),
  CityAreaInfo("滨州市", [
    GeneralType('不限', 'binzhou_area_any'),
    GeneralType('滨城区', '滨城区'), GeneralType('惠民县', '惠民县'), GeneralType('阳信县', '阳信县'), GeneralType('无棣县', '无棣县'), GeneralType('沾化县', '沾化县'), GeneralType('博兴县', '博兴县'), GeneralType('邹平县', '邹平县'),
  ]),
  CityAreaInfo("菏泽市", [
    GeneralType('不限', 'heze_area_any'),
    GeneralType('牡丹区', '牡丹区'), GeneralType('曹县', '曹县'), GeneralType('单县', '单县'), GeneralType('成武县', '成武县'), GeneralType('巨野县', '巨野县'), GeneralType('郓城县', '郓城县'), GeneralType('鄄城县', '鄄城县'), GeneralType('定陶县', '定陶县'), GeneralType('东明县', '东明县'),
  ]),
  CityAreaInfo("郑州市", [
    GeneralType('不限', 'zhengzhou_area_any'),
    GeneralType('中原区', '中原区'), GeneralType('二七区', '二七区'), GeneralType('管城回族区', '管城回族区'), GeneralType('金水区', '金水区'), GeneralType('上街区', '上街区'), GeneralType('惠济区', '惠济区'), GeneralType('中牟县', '中牟县'), GeneralType('巩义市', '巩义市'), GeneralType('荥阳市', '荥阳市'), GeneralType('新密市', '新密市'), GeneralType('新郑市', '新郑市'), GeneralType('登封市', '登封市'),
  ]),
  CityAreaInfo("开封市", [
    GeneralType('不限', 'kaifeng_area_any'),
    GeneralType('龙亭区', '龙亭区'), GeneralType('顺河回族区', '顺河回族区'), GeneralType('鼓楼区', '鼓楼区'), GeneralType('禹王台区', '禹王台区'), GeneralType('金明区', '金明区'), GeneralType('杞县', '杞县'), GeneralType('通许县', '通许县'), GeneralType('尉氏县', '尉氏县'), GeneralType('开封县', '开封县'), GeneralType('兰考县', '兰考县'),
  ]),
  CityAreaInfo("洛阳市", [
    GeneralType('不限', 'luoyang_area_any'),
    GeneralType('老城区', '老城区'), GeneralType('西工区', '西工区'), GeneralType('瀍河回族区', '瀍河回族区'), GeneralType('涧西区', '涧西区'), GeneralType('吉利区', '吉利区'), GeneralType('洛龙区', '洛龙区'), GeneralType('孟津县', '孟津县'), GeneralType('新安县', '新安县'), GeneralType('栾川县', '栾川县'), GeneralType('嵩县', '嵩县'), GeneralType('汝阳县', '汝阳县'), GeneralType('宜阳县', '宜阳县'), GeneralType('洛宁县', '洛宁县'), GeneralType('伊川县', '伊川县'), GeneralType('偃师市', '偃师市'),
  ]),
  CityAreaInfo("平顶山市", [
    GeneralType('不限', 'pingdingshan_area_any'),
    GeneralType('新华区', '新华区'), GeneralType('卫东区', '卫东区'), GeneralType('石龙区', '石龙区'), GeneralType('湛河区', '湛河区'), GeneralType('宝丰县', '宝丰县'), GeneralType('叶县', '叶县'), GeneralType('鲁山县', '鲁山县'), GeneralType('郏县', '郏县'), GeneralType('舞钢市', '舞钢市'), GeneralType('汝州市', '汝州市'),
  ]),
  CityAreaInfo("安阳市", [
    GeneralType('不限', 'anyang_area_any'),
    GeneralType('文峰区', '文峰区'), GeneralType('北关区', '北关区'), GeneralType('殷都区', '殷都区'), GeneralType('龙安区', '龙安区'), GeneralType('安阳县', '安阳县'), GeneralType('汤阴县', '汤阴县'), GeneralType('滑县', '滑县'), GeneralType('内黄县', '内黄县'), GeneralType('林州市', '林州市'),
  ]),
  CityAreaInfo("鹤壁市", [
    GeneralType('不限', 'hebi_area_any'),
    GeneralType('鹤山区', '鹤山区'), GeneralType('山城区', '山城区'), GeneralType('淇滨区', '淇滨区'), GeneralType('浚县', '浚县'), GeneralType('淇县', '淇县'),
  ]),
  CityAreaInfo("新乡市", [
    GeneralType('不限', 'xinxiang_area_any'),
    GeneralType('红旗区', '红旗区'), GeneralType('卫滨区', '卫滨区'), GeneralType('凤泉区', '凤泉区'), GeneralType('牧野区', '牧野区'), GeneralType('新乡县', '新乡县'), GeneralType('获嘉县', '获嘉县'), GeneralType('原阳县', '原阳县'), GeneralType('延津县', '延津县'), GeneralType('封丘县', '封丘县'), GeneralType('长垣县', '长垣县'), GeneralType('卫辉市', '卫辉市'), GeneralType('辉县市', '辉县市'),
  ]),
  CityAreaInfo("焦作市", [
    GeneralType('不限', 'jiaozuo_area_any'),
    GeneralType('解放区', '解放区'), GeneralType('中站区', '中站区'), GeneralType('马村区', '马村区'), GeneralType('山阳区', '山阳区'), GeneralType('修武县', '修武县'), GeneralType('博爱县', '博爱县'), GeneralType('武陟县', '武陟县'), GeneralType('温县', '温县'), GeneralType('沁阳市', '沁阳市'), GeneralType('孟州市', '孟州市'),
  ]),
  CityAreaInfo("濮阳市", [
    GeneralType('不限', 'puyang_area_any'),
    GeneralType('华龙区', '华龙区'), GeneralType('清丰县', '清丰县'), GeneralType('南乐县', '南乐县'), GeneralType('范县', '范县'), GeneralType('台前县', '台前县'), GeneralType('濮阳县', '濮阳县'),
  ]),
  CityAreaInfo("许昌市", [
    GeneralType('不限', 'xuchang_area_any'),
    GeneralType('魏都区', '魏都区'), GeneralType('许昌县', '许昌县'), GeneralType('鄢陵县', '鄢陵县'), GeneralType('襄城县', '襄城县'), GeneralType('禹州市', '禹州市'), GeneralType('长葛市', '长葛市'),
  ]),
  CityAreaInfo("漯河市", [
    GeneralType('不限', 'luohe_henan_area_any'),
    GeneralType('源汇区', '源汇区'), GeneralType('郾城区', '郾城区'), GeneralType('召陵区', '召陵区'), GeneralType('舞阳县', '舞阳县'), GeneralType('临颍县', '临颍县'),
  ]),
  CityAreaInfo("三门峡市", [
    GeneralType('不限', 'sanmenxia_area_any'),
    GeneralType('湖滨区', '湖滨区'), GeneralType('渑池县', '渑池县'), GeneralType('陕县', '陕县'), GeneralType('卢氏县', '卢氏县'), GeneralType('义马市', '义马市'), GeneralType('灵宝市', '灵宝市'),
  ]),
  CityAreaInfo("南阳市", [
    GeneralType('不限', 'nanyang_area_any'),
    GeneralType('宛城区', '宛城区'), GeneralType('卧龙区', '卧龙区'), GeneralType('南召县', '南召县'), GeneralType('方城县', '方城县'), GeneralType('西峡县', '西峡县'), GeneralType('镇平县', '镇平县'), GeneralType('内乡县', '内乡县'), GeneralType('淅川县', '淅川县'), GeneralType('社旗县', '社旗县'), GeneralType('唐河县', '唐河县'), GeneralType('新野县', '新野县'), GeneralType('桐柏县', '桐柏县'), GeneralType('邓州市', '邓州市'),
  ]),
  CityAreaInfo("商丘市", [
    GeneralType('不限', 'shangqiu_area_any'),
    GeneralType('梁园区', '梁园区'), GeneralType('睢阳区', '睢阳区'), GeneralType('民权县', '民权县'), GeneralType('睢县', '睢县'), GeneralType('宁陵县', '宁陵县'), GeneralType('柘城县', '柘城县'), GeneralType('虞城县', '虞城县'), GeneralType('夏邑县', '夏邑县'), GeneralType('永城市', '永城市'),
  ]),
  CityAreaInfo("信阳市", [
    GeneralType('不限', 'xinyang_hn_area_any'),
    GeneralType('浉河区', '浉河区'), GeneralType('平桥区', '平桥区'), GeneralType('罗山县', '罗山县'), GeneralType('光山县', '光山县'), GeneralType('新县', '新县'), GeneralType('商城县', '商城县'), GeneralType('固始县', '固始县'), GeneralType('潢川县', '潢川县'), GeneralType('淮滨县', '淮滨县'), GeneralType('息县', '息县'),
  ]),
  CityAreaInfo("周口市", [
    GeneralType('不限', 'zhoukou_area_any'),
    GeneralType('川汇区', '川汇区'), GeneralType('扶沟县', '扶沟县'), GeneralType('西华县', '西华县'), GeneralType('商水县', '商水县'), GeneralType('沈丘县', '沈丘县'), GeneralType('郸城县', '郸城县'), GeneralType('淮阳县', '淮阳县'), GeneralType('太康县', '太康县'), GeneralType('鹿邑县', '鹿邑县'), GeneralType('项城市', '项城市'),
  ]),
  CityAreaInfo("驻马店市", [
    GeneralType('不限', 'zhumadian_area_any'),
    GeneralType('驿城区', '驿城区'), GeneralType('西平县', '西平县'), GeneralType('上蔡县', '上蔡县'), GeneralType('平舆县', '平舆县'), GeneralType('正阳县', '正阳县'), GeneralType('确山县', '确山县'), GeneralType('泌阳县', '泌阳县'), GeneralType('汝南县', '汝南县'), GeneralType('遂平县', '遂平县'), GeneralType('新蔡县', '新蔡县'),
  ]),
  CityAreaInfo("济源市", [ GeneralType('不限', 'jiyuan_area_any'), GeneralType('济源市', '济源市')]),
  CityAreaInfo("武汉市", [
    GeneralType('不限', 'wuhan_area_any'),
    GeneralType('江岸区', '江岸区'), GeneralType('江汉区', '江汉区'), GeneralType('硚口区', '硚口区'), GeneralType('汉阳区', '汉阳区'), GeneralType('武昌区', '武昌区'), GeneralType('青山区', '青山区'), GeneralType('洪山区', '洪山区'), GeneralType('东西湖区', '东西湖区'), GeneralType('汉南区', '汉南区'), GeneralType('蔡甸区', '蔡甸区'), GeneralType('江夏区', '江夏区'), GeneralType('黄陂区', '黄陂区'), GeneralType('新洲区', '新洲区'),
  ]),
  CityAreaInfo("黄石市", [
    GeneralType('不限', 'huangshi_area_any'),
    GeneralType('黄石港区', '黄石港区'), GeneralType('西塞山区', '西塞山区'), GeneralType('下陆区', '下陆区'), GeneralType('铁山区', '铁山区'), GeneralType('阳新县', '阳新县'), GeneralType('大冶市', '大冶市'),
  ]),
  CityAreaInfo("十堰市", [
    GeneralType('不限', 'shiyan_area_any'),
    GeneralType('茅箭区', '茅箭区'), GeneralType('张湾区', '张湾区'), GeneralType('郧县', '郧县'), GeneralType('郧西县', '郧西县'), GeneralType('竹山县', '竹山县'), GeneralType('竹溪县', '竹溪县'), GeneralType('房县', '房县'), GeneralType('丹江口市', '丹江口市'),
  ]),
  CityAreaInfo("宜昌市", [
    GeneralType('不限', 'yichang_hb_area_any'),
    GeneralType('西陵区', '西陵区'), GeneralType('伍家岗区', '伍家岗区'), GeneralType('点军区', '点军区'), GeneralType('猇亭区', '猇亭区'), GeneralType('夷陵区', '夷陵区'), GeneralType('远安县', '远安县'), GeneralType('兴山县', '兴山县'), GeneralType('秭归县', '秭归县'), GeneralType('长阳土家族自治县', '长阳土家族自治县'), GeneralType('五峰土家族自治县', '五峰土家族自治县'), GeneralType('宜都市', '宜都市'), GeneralType('当阳市', '当阳市'), GeneralType('枝江市', '枝江市'),
  ]),
  CityAreaInfo("襄樊市", [
    GeneralType('不限', 'xiangfan_area_any'),
    GeneralType('襄城区', '襄城区'), GeneralType('樊城区', '樊城区'), GeneralType('襄阳区', '襄阳区'), GeneralType('南漳县', '南漳县'), GeneralType('谷城县', '谷城县'), GeneralType('保康县', '保康县'), GeneralType('老河口市', '老河口市'), GeneralType('枣阳市', '枣阳市'), GeneralType('宜城市', '宜城市'),
  ]),
  CityAreaInfo("鄂州市", [
    GeneralType('不限', 'ezhou_area_any'),
    GeneralType('梁子湖区', '梁子湖区'), GeneralType('华容区', '华容区'), GeneralType('鄂城区', '鄂城区'),
  ]),
  CityAreaInfo("荆门市", [
    GeneralType('不限', 'jingmen_area_any'),
    GeneralType('东宝区', '东宝区'), GeneralType('掇刀区', '掇刀区'), GeneralType('京山县', '京山县'), GeneralType('沙洋县', '沙洋县'), GeneralType('钟祥市', '钟祥市'),
  ]),
  CityAreaInfo("孝感市", [
    GeneralType('不限', 'xiaogan_area_any'),
    GeneralType('孝南区', '孝南区'), GeneralType('孝昌县', '孝昌县'), GeneralType('大悟县', '大悟县'), GeneralType('云梦县', '云梦县'), GeneralType('应城市', '应城市'), GeneralType('安陆市', '安陆市'), GeneralType('汉川市', '汉川市'),
  ]),
  CityAreaInfo("荆州市", [
    GeneralType('不限', 'jingzhou_area_any'),
    GeneralType('沙市区', '沙市区'), GeneralType('荆州区', '荆州区'), GeneralType('公安县', '公安县'), GeneralType('监利县', '监利县'), GeneralType('江陵县', '江陵县'), GeneralType('石首市', '石首市'), GeneralType('洪湖市', '洪湖市'), GeneralType('松滋市', '松滋市'),
  ]),
  CityAreaInfo("黄冈市", [
    GeneralType('不限', 'huanggang_hb_area_any'),
    GeneralType('黄州区', '黄州区'), GeneralType('团风县', '团风县'), GeneralType('红安县', '红安县'), GeneralType('罗田县', '罗田县'), GeneralType('英山县', '英山县'), GeneralType('浠水县', '浠水县'), GeneralType('蕲春县', '蕲春县'), GeneralType('黄梅县', '黄梅县'), GeneralType('麻城市', '麻城市'), GeneralType('武穴市', '武穴市'),
  ]),
  CityAreaInfo("咸宁市", [
    GeneralType('不限', 'xianning_hb_area_any'),
    GeneralType('咸安区', '咸安区'), GeneralType('嘉鱼县', '嘉鱼县'), GeneralType('通城县', '通城县'), GeneralType('崇阳县', '崇阳县'), GeneralType('通山县', '通山县'), GeneralType('赤壁市', '赤壁市'),
  ]),
  CityAreaInfo("随州市", [
    GeneralType('不限', 'suizhou_hb_area_any'),
    GeneralType('曾都区', '曾都区'), GeneralType('随县', '随县'), GeneralType('广水市', '广水市'),
  ]),
  CityAreaInfo("恩施土家族苗族自治州", [
    GeneralType('不限', 'enshi_area_any'),
    GeneralType('恩施市', '恩施市'), GeneralType('利川市', '利川市'), GeneralType('建始县', '建始县'), GeneralType('巴东县', '巴东县'), GeneralType('宣恩县', '宣恩县'), GeneralType('咸丰县', '咸丰县'), GeneralType('来凤县', '来凤县'), GeneralType('鹤峰县', '鹤峰县'),
  ]),
  CityAreaInfo("仙桃市", [ GeneralType('不限', 'xiantao_area_any'), GeneralType('仙桃市', '仙桃市')]),
  CityAreaInfo("潜江市", [ GeneralType('不限', 'qianjiang_area_any'), GeneralType('潜江市', '潜江市')]),
  CityAreaInfo("天门市", [ GeneralType('不限', 'tianmen_area_any'), GeneralType('天门市', '天门市')]),
  CityAreaInfo("神农架林区", [ GeneralType('不限', 'shennongjia_area_any'), GeneralType('神农架林区', '神农架林区')]),
  CityAreaInfo("长沙市", [
    GeneralType('不限', 'changsha_area_any'),
    GeneralType('芙蓉区', '芙蓉区'), GeneralType('天心区', '天心区'), GeneralType('岳麓区', '岳麓区'), GeneralType('开福区', '开福区'), GeneralType('雨花区', '雨花区'), GeneralType('长沙县', '长沙县'), GeneralType('望城县', '望城县'), GeneralType('宁乡县', '宁乡县'), GeneralType('浏阳市', '浏阳市'),
  ]),
  CityAreaInfo("株洲市", [
    GeneralType('不限', 'zhuzhou_hunan_area_any'),
    GeneralType('荷塘区', '荷塘区'), GeneralType('芦淞区', '芦淞区'), GeneralType('石峰区', '石峰区'), GeneralType('天元区', '天元区'), GeneralType('株洲县', '株洲县'), GeneralType('攸县', '攸县'), GeneralType('茶陵县', '茶陵县'), GeneralType('炎陵县', '炎陵县'), GeneralType('醴陵市', '醴陵市'),
  ]),
  CityAreaInfo("湘潭市", [
    GeneralType('不限', 'xiangtan_hunan_area_any'),
    GeneralType('雨湖区', '雨湖区'), GeneralType('岳塘区', '岳塘区'), GeneralType('湘潭县', '湘潭县'), GeneralType('湘乡市', '湘乡市'), GeneralType('韶山市', '韶山市'),
  ]),
  CityAreaInfo("衡阳市", [
    GeneralType('不限', 'hengyang_area_any'),
    GeneralType('珠晖区', '珠晖区'), GeneralType('雁峰区', '雁峰区'), GeneralType('石鼓区', '石鼓区'), GeneralType('蒸湘区', '蒸湘区'), GeneralType('南岳区', '南岳区'), GeneralType('衡阳县', '衡阳县'), GeneralType('衡南县', '衡南县'), GeneralType('衡山县', '衡山县'), GeneralType('衡东县', '衡东县'), GeneralType('祁东县', '祁东县'), GeneralType('耒阳市', '耒阳市'), GeneralType('常宁市', '常宁市'),
  ]),
  CityAreaInfo("邵阳市", [
    GeneralType('不限', 'shaoyang_area_any'),
    GeneralType('双清区', '双清区'), GeneralType('大祥区', '大祥区'), GeneralType('北塔区', '北塔区'), GeneralType('邵东县', '邵东县'), GeneralType('新邵县', '新邵县'), GeneralType('邵阳县', '邵阳县'), GeneralType('隆回县', '隆回县'), GeneralType('洞口县', '洞口县'), GeneralType('绥宁县', '绥宁县'), GeneralType('新宁县', '新宁县'), GeneralType('城步苗族自治县', '城步苗族自治县'), GeneralType('武冈市', '武冈市'),
  ]),
  CityAreaInfo("岳阳市", [
    GeneralType('不限', 'yueyang_area_any'),
    GeneralType('岳阳楼区', '岳阳楼区'), GeneralType('云溪区', '云溪区'), GeneralType('君山区', '君山区'), GeneralType('岳阳县', '岳阳县'), GeneralType('华容县', '华容县'), GeneralType('湘阴县', '湘阴县'), GeneralType('平江县', '平江县'), GeneralType('汨罗市', '汨罗市'), GeneralType('临湘市', '临湘市'),
  ]),
  CityAreaInfo("常德市", [
    GeneralType('不限', 'changde_area_any'),
    GeneralType('武陵区', '武陵区'), GeneralType('鼎城区', '鼎城区'), GeneralType('安乡县', '安乡县'), GeneralType('汉寿县', '汉寿县'), GeneralType('澧县', '澧县'), GeneralType('临澧县', '临澧县'), GeneralType('桃源县', '桃源县'), GeneralType('石门县', '石门县'), GeneralType('津市市', '津市市'),
  ]),
  CityAreaInfo("张家界市", [
    GeneralType('不限', 'zhangjiajie_area_any'),
    GeneralType('永定区', '永定区'), GeneralType('武陵源区', '武陵源区'), GeneralType('慈利县', '慈利县'), GeneralType('桑植县', '桑植县'),
  ]),
  CityAreaInfo("益阳市", [
    GeneralType('不限', 'yiyang_area_any'),
    GeneralType('资阳区', '资阳区'), GeneralType('赫山区', '赫山区'), GeneralType('南县', '南县'), GeneralType('桃江县', '桃江县'), GeneralType('安化县', '安化县'), GeneralType('沅江市', '沅江市'),
  ]),
  CityAreaInfo("郴州市", [
    GeneralType('不限', 'chenzhou_area_any'),
    GeneralType('北湖区', '北湖区'), GeneralType('苏仙区', '苏仙区'), GeneralType('桂阳县', '桂阳县'), GeneralType('宜章县', '宜章县'), GeneralType('永兴县', '永兴县'), GeneralType('嘉禾县', '嘉禾县'), GeneralType('临武县', '临武县'), GeneralType('汝城县', '汝城县'), GeneralType('桂东县', '桂东县'), GeneralType('安仁县', '安仁县'), GeneralType('资兴市', '资兴市'),
  ]),
  CityAreaInfo("永州市", [
    GeneralType('不限', 'yongzhou_area_any'),
    GeneralType('零陵区', '零陵区'), GeneralType('冷水滩区', '冷水滩区'), GeneralType('祁阳县', '祁阳县'), GeneralType('东安县', '东安县'), GeneralType('双牌县', '双牌县'), GeneralType('道县', '道县'), GeneralType('江永县', '江永县'), GeneralType('宁远县', '宁远县'), GeneralType('蓝山县', '蓝山县'), GeneralType('新田县', '新田县'), GeneralType('江华瑶族自治县', '江华瑶族自治县'),
  ]),
  CityAreaInfo("怀化市", [
    GeneralType('不限', 'huaihua_hunan_area_any'),
    GeneralType('鹤城区', '鹤城区'), GeneralType('中方县', '中方县'), GeneralType('沅陵县', '沅陵县'), GeneralType('辰溪县', '辰溪县'), GeneralType('溆浦县', '溆浦县'), GeneralType('会同县', '会同县'), GeneralType('麻阳苗族自治县', '麻阳苗族自治县'), GeneralType('新晃侗族自治县', '新晃侗族自治县'), GeneralType('芷江侗族自治县', '芷江侗族自治县'), GeneralType('靖州苗族侗族自治县', '靖州苗族侗族自治县'), GeneralType('通道侗族自治县', '通道侗族自治县'), GeneralType('洪江市', '洪江市'),
  ]),
  CityAreaInfo("娄底市", [
    GeneralType('不限', 'loudi_hunan_area_any'),
    GeneralType('娄星区', '娄星区'), GeneralType('双峰县', '双峰县'), GeneralType('新化县', '新化县'), GeneralType('冷水江市', '冷水江市'), GeneralType('涟源市', '涟源市'),
  ]),
  CityAreaInfo("湘西土家族苗族自治州", [
    GeneralType('不限', 'xiangxi_zz_area_any'),
    GeneralType('吉首市', '吉首市'), GeneralType('泸溪县', '泸溪县'), GeneralType('凤凰县', '凤凰县'), GeneralType('花垣县', '花垣县'), GeneralType('保靖县', '保靖县'), GeneralType('古丈县', '古丈县'), GeneralType('永顺县', '永顺县'), GeneralType('龙山县', '龙山县'),
  ]),
  CityAreaInfo("广州市", [
    GeneralType('不限', 'guangzhou_area_any'),
    GeneralType('荔湾区', '荔湾区'), GeneralType('越秀区', '越秀区'), GeneralType('海珠区', '海珠区'), GeneralType('天河区', '天河区'), GeneralType('白云区', '白云区'), GeneralType('黄埔区', '黄埔区'), GeneralType('番禺区', '番禺区'), GeneralType('花都区', '花都区'), GeneralType('南沙区', '南沙区'), GeneralType('萝岗区', '萝岗区'), GeneralType('增城市', '增城市'), GeneralType('从化市', '从化市'),
  ]),
  CityAreaInfo("韶关市", [
    GeneralType('不限', 'shaoguan_area_any'),
    GeneralType('武江区', '武江区'), GeneralType('浈江区', '浈江区'), GeneralType('曲江区', '曲江区'), GeneralType('始兴县', '始兴县'), GeneralType('仁化县', '仁化县'), GeneralType('翁源县', '翁源县'), GeneralType('乳源瑶族自治县', '乳源瑶族自治县'), GeneralType('新丰县', '新丰县'), GeneralType('乐昌市', '乐昌市'), GeneralType('南雄市', '南雄市'),
  ]),
  CityAreaInfo("深圳市", [
    GeneralType('不限', 'shenzhen_area_any'),
    GeneralType('罗湖区', '罗湖区'), GeneralType('福田区', '福田区'), GeneralType('南山区', '南山区'), GeneralType('宝安区', '宝安区'), GeneralType('龙岗区', '龙岗区'), GeneralType('盐田区', '盐田区'),
  ]),
  CityAreaInfo("珠海市", [
    GeneralType('不限', 'zhuhai_area_any'),
    GeneralType('香洲区', '香洲区'), GeneralType('斗门区', '斗门区'), GeneralType('金湾区', '金湾区'),
  ]),
  CityAreaInfo("汕头市", [
    GeneralType('不限', 'shantou_area_any'),
    GeneralType('龙湖区', '龙湖区'), GeneralType('金平区', '金平区'), GeneralType('濠江区', '濠江区'), GeneralType('潮阳区', '潮阳区'), GeneralType('潮南区', '潮南区'), GeneralType('澄海区', '澄海区'), GeneralType('南澳县', '南澳县'),
  ]),
  CityAreaInfo("佛山市", [
    GeneralType('不限', 'foshan_area_any'),
    GeneralType('禅城区', '禅城区'), GeneralType('南海区', '南海区'), GeneralType('顺德区', '顺德区'), GeneralType('三水区', '三水区'), GeneralType('高明区', '高明区'),
  ]),
  CityAreaInfo("江门市", [
    GeneralType('不限', 'jiangmen_area_any'),
    GeneralType('蓬江区', '蓬江区'), GeneralType('江海区', '江海区'), GeneralType('新会区', '新会区'), GeneralType('台山市', '台山市'), GeneralType('开平市', '开平市'), GeneralType('鹤山市', '鹤山市'), GeneralType('恩平市', '恩平市'),
  ]),
  CityAreaInfo("湛江市", [
    GeneralType('不限', 'zhanjiang_area_any'),
    GeneralType('赤坎区', '赤坎区'), GeneralType('霞山区', '霞山区'), GeneralType('坡头区', '坡头区'), GeneralType('麻章区', '麻章区'), GeneralType('遂溪县', '遂溪县'), GeneralType('徐闻县', '徐闻县'), GeneralType('廉江市', '廉江市'), GeneralType('雷州市', '雷州市'), GeneralType('吴川市', '吴川市'),
  ]),
  CityAreaInfo("茂名市", [
    GeneralType('不限', 'maoming_area_any'),
    GeneralType('茂南区', '茂南区'), GeneralType('茂港区', '茂港区'), GeneralType('电白县', '电白县'), GeneralType('高州市', '高州市'), GeneralType('化州市', '化州市'), GeneralType('信宜市', '信宜市'),
  ]),
  CityAreaInfo("肇庆市", [
    GeneralType('不限', 'zhaoqing_area_any'),
    GeneralType('端州区', '端州区'), GeneralType('鼎湖区', '鼎湖区'), GeneralType('广宁县', '广宁县'), GeneralType('怀集县', '怀集县'), GeneralType('封开县', '封开县'), GeneralType('德庆县', '德庆县'), GeneralType('高要市', '高要市'), GeneralType('四会市', '四会市'),
  ]),
  CityAreaInfo("惠州市", [
    GeneralType('不限', 'huizhou_area_any'),
    GeneralType('惠城区', '惠城区'), GeneralType('惠阳区', '惠阳区'), GeneralType('博罗县', '博罗县'), GeneralType('惠东县', '惠东县'), GeneralType('龙门县', '龙门县'),
  ]),
  CityAreaInfo("梅州市", [
    GeneralType('不限', 'meizhou_area_any'),
    GeneralType('梅江区', '梅江区'), GeneralType('梅县', '梅县'), GeneralType('大埔县', '大埔县'), GeneralType('丰顺县', '丰顺县'), GeneralType('五华县', '五华县'), GeneralType('平远县', '平远县'), GeneralType('蕉岭县', '蕉岭县'), GeneralType('兴宁市', '兴宁市'),
  ]),
  CityAreaInfo("汕尾市", [
    GeneralType('不限', 'shanwei_area_any'),
    GeneralType('城区', '城区'), GeneralType('海丰县', '海丰县'), GeneralType('陆河县', '陆河县'), GeneralType('陆丰市', '陆丰市'),
  ]),
  CityAreaInfo("河源市", [
    GeneralType('不限', 'heyuan_area_any'),
    GeneralType('源城区', '源城区'), GeneralType('紫金县', '紫金县'), GeneralType('龙川县', '龙川县'), GeneralType('连平县', '连平县'), GeneralType('和平县', '和平县'), GeneralType('东源县', '东源县'),
  ]),
  CityAreaInfo("阳江市", [
    GeneralType('不限', 'yangjiang_area_any'),
    GeneralType('江城区', '江城区'), GeneralType('阳西县', '阳西县'), GeneralType('阳东县', '阳东县'), GeneralType('阳春市', '阳春市'),
  ]),
  CityAreaInfo("清远市", [
    GeneralType('不限', 'qingyuan_area_any'),
    GeneralType('清城区', '清城区'), GeneralType('佛冈县', '佛冈县'), GeneralType('阳山县', '阳山县'), GeneralType('连山壮族瑶族自治县', '连山壮族瑶族自治县'), GeneralType('连南瑶族自治县', '连南瑶族自治县'), GeneralType('清新县', '清新县'), GeneralType('英德市', '英德市'), GeneralType('连州市', '连州市'),
  ]),
  CityAreaInfo("东莞市", [ GeneralType('不限', 'dongguan_area_any'), GeneralType('东莞市', '东莞市')]),
  CityAreaInfo("中山市", [ GeneralType('不限', 'zhongshan_area_any'), GeneralType('中山市', '中山市')]),
  CityAreaInfo("潮州市", [
    GeneralType('不限', 'chaozhou_area_any'),
    GeneralType('湘桥区', '湘桥区'), GeneralType('潮安县', '潮安县'), GeneralType('饶平县', '饶平县'),
  ]),
  CityAreaInfo("揭阳市", [
    GeneralType('不限', 'jieyang_area_any'),
    GeneralType('榕城区', '榕城区'), GeneralType('揭东县', '揭东县'), GeneralType('揭西县', '揭西县'), GeneralType('惠来县', '惠来县'), GeneralType('普宁市', '普宁市'),
  ]),
  CityAreaInfo("云浮市", [
    GeneralType('不限', 'yunfu_area_any'),
    GeneralType('云城区', '云城区'), GeneralType('新兴县', '新兴县'), GeneralType('郁南县', '郁南县'), GeneralType('云安县', '云安县'), GeneralType('罗定市', '罗定市'),
  ]),
  CityAreaInfo("南宁市", [
    GeneralType('不限', 'nanning_area_any'),
    GeneralType('兴宁区', '兴宁区'), GeneralType('青秀区', '青秀区'), GeneralType('江南区', '江南区'), GeneralType('西乡塘区', '西乡塘区'), GeneralType('良庆区', '良庆区'), GeneralType('邕宁区', '邕宁区'), GeneralType('武鸣县', '武鸣县'), GeneralType('隆安县', '隆安县'), GeneralType('马山县', '马山县'), GeneralType('上林县', '上林县'), GeneralType('宾阳县', '宾阳县'), GeneralType('横县', '横县'),
  ]),
  CityAreaInfo("柳州市", [
    GeneralType('不限', 'liuzhou_area_any'),
    GeneralType('城中区', '城中区'), GeneralType('鱼峰区', '鱼峰区'), GeneralType('柳南区', '柳南区'), GeneralType('柳北区', '柳北区'), GeneralType('柳江县', '柳江县'), GeneralType('柳城县', '柳城县'), GeneralType('鹿寨县', '鹿寨县'), GeneralType('融安县', '融安县'), GeneralType('融水苗族自治县', '融水苗族自治县'), GeneralType('三江侗族自治县', '三江侗族自治县'),
  ]),
  CityAreaInfo("桂林市", [
    GeneralType('不限', 'guilin_area_any'),
    GeneralType('秀峰区', '秀峰区'), GeneralType('叠彩区', '叠彩区'), GeneralType('象山区', '象山区'), GeneralType('七星区', '七星区'), GeneralType('雁山区', '雁山区'), GeneralType('阳朔县', '阳朔县'), GeneralType('临桂县', '临桂县'), GeneralType('灵川县', '灵川县'), GeneralType('全州县', '全州县'), GeneralType('兴安县', '兴安县'), GeneralType('永福县', '永福县'), GeneralType('灌阳县', '灌阳县'), GeneralType('龙胜各族自治县', '龙胜各族自治县'), GeneralType('资源县', '资源县'), GeneralType('平乐县', '平乐县'), GeneralType('荔蒲县', '荔蒲县'), GeneralType('恭城瑶族自治县', '恭城瑶族自治县'),
  ]),
  CityAreaInfo("梧州市", [
    GeneralType('不限', 'wuzhou_area_any'),
    GeneralType('万秀区', '万秀区'), GeneralType('蝶山区', '蝶山区'), GeneralType('长洲区', '长洲区'), GeneralType('苍梧县', '苍梧县'), GeneralType('藤县', '藤县'), GeneralType('蒙山县', '蒙山县'), GeneralType('岑溪市', '岑溪市'),
  ]),
  CityAreaInfo("北海市", [
    GeneralType('不限', 'beihai_area_any'),
    GeneralType('海城区', '海城区'), GeneralType('银海区', '银海区'), GeneralType('铁山港区', '铁山港区'), GeneralType('合浦县', '合浦县'),
  ]),
  CityAreaInfo("防城港市", [
    GeneralType('不限', 'fangchenggang_area_any'),
    GeneralType('港口区', '港口区'), GeneralType('防城区', '防城区'), GeneralType('上思县', '上思县'), GeneralType('东兴市', '东兴市'),
  ]),
  CityAreaInfo("钦州市", [
    GeneralType('不限', 'qinzhou_area_any'),
    GeneralType('钦南区', '钦南区'), GeneralType('钦北区', '钦北区'), GeneralType('灵山县', '灵山县'), GeneralType('浦北县', '浦北县'),
  ]),
  CityAreaInfo("贵港市", [
    GeneralType('不限', 'guigang_area_any'),
    GeneralType('港北区', '港北区'), GeneralType('港南区', '港南区'), GeneralType('覃塘区', '覃塘区'), GeneralType('平南县', '平南县'), GeneralType('桂平市', '桂平市'),
  ]),
  CityAreaInfo("玉林市", [
    GeneralType('不限', 'yulin_gx_area_any'),
    GeneralType('玉州区', '玉州区'), GeneralType('容县', '容县'), GeneralType('陆川县', '陆川县'), GeneralType('博白县', '博白县'), GeneralType('兴业县', '兴业县'), GeneralType('北流市', '北流市'),
  ]),
  CityAreaInfo("百色市", [
    GeneralType('不限', 'baise_area_any'),
    GeneralType('右江区', '右江区'), GeneralType('田阳县', '田阳县'), GeneralType('田东县', '田东县'), GeneralType('平果县', '平果县'), GeneralType('德保县', '德保县'), GeneralType('靖西县', '靖西县'), GeneralType('那坡县', '那坡县'), GeneralType('凌云县', '凌云县'), GeneralType('乐业县', '乐业县'), GeneralType('田林县', '田林县'), GeneralType('西林县', '西林县'), GeneralType('隆林各族自治县', '隆林各族自治县'),
  ]),
  CityAreaInfo("贺州市", [
    GeneralType('不限', 'hezhou_area_any'),
    GeneralType('八步区', '八步区'), GeneralType('平桂管理区', '平桂管理区'), GeneralType('昭平县', '昭平县'), GeneralType('钟山县', '钟山县'), GeneralType('富川瑶族自治县', '富川瑶族自治县'),
  ]),
  CityAreaInfo("河池市", [
    GeneralType('不限', 'hechi_area_any'),
    GeneralType('金城江区', '金城江区'), GeneralType('南丹县', '南丹县'), GeneralType('天峨县', '天峨县'), GeneralType('凤山县', '凤山县'), GeneralType('东兰县', '东兰县'), GeneralType('罗城仫佬族自治县', '罗城仫佬族自治县'), GeneralType('环江毛南族自治县', '环江毛南族自治县'), GeneralType('巴马瑶族自治县', '巴马瑶族自治县'), GeneralType('都安瑶族自治县', '都安瑶族自治县'), GeneralType('大化瑶族自治县', '大化瑶族自治县'), GeneralType('宜州市', '宜州市'),
  ]),
  CityAreaInfo("来宾市", [
    GeneralType('不限', 'laibin_area_any'),
    GeneralType('兴宾区', '兴宾区'), GeneralType('忻城县', '忻城县'), GeneralType('象州县', '象州县'), GeneralType('武宣县', '武宣县'), GeneralType('金秀瑶族自治县', '金秀瑶族自治县'), GeneralType('合山市', '合山市'),
  ]),
  CityAreaInfo("崇左市", [
    GeneralType('不限', 'chongzuo_area_any'),
    GeneralType('江洲区', '江洲区'), GeneralType('扶绥县', '扶绥县'), GeneralType('宁明县', '宁明县'), GeneralType('龙州县', '龙州县'), GeneralType('大新县', '大新县'), GeneralType('天等县', '天等县'), GeneralType('凭祥市', '凭祥市'),
  ]),
  CityAreaInfo("海口市", [
    GeneralType('不限', 'haikou_area_any'),
    GeneralType('秀英区', '秀英区'), GeneralType('龙华区', '龙华区'), GeneralType('琼山区', '琼山区'), GeneralType('美兰区', '美兰区'),
  ]),
  CityAreaInfo("三亚市", [ GeneralType('不限', 'sanya_hn_area_any'), GeneralType('三亚市', '三亚市')]),
  CityAreaInfo("五指山市", [ GeneralType('不限', 'wuzhishan_area_any'), GeneralType('五指山市', '五指山市')]),
  CityAreaInfo("琼海市", [ GeneralType('不限', 'qionghai_area_any'), GeneralType('琼海市', '琼海市')]),
  CityAreaInfo("儋州市", [ GeneralType('不限', 'danzhou_area_any'), GeneralType('儋州市', '儋州市')]),
  CityAreaInfo("文昌市", [ GeneralType('不限', 'wenchang_area_any'), GeneralType('文昌市', '文昌市')]),
  CityAreaInfo("万宁市", [ GeneralType('不限', 'wanning_area_any'), GeneralType('万宁市', '万宁市')]),
  CityAreaInfo("东方市", [ GeneralType('不限', 'dongfang_area_any'), GeneralType('东方市', '东方市')]),
  CityAreaInfo("定安县", [ GeneralType('不限', 'dingan_area_any'), GeneralType('定安县', '定安县')]),
  CityAreaInfo("屯昌县", [ GeneralType('不限', 'tunchang_area_any'), GeneralType('屯昌县', '屯昌县')]),
  CityAreaInfo("澄迈县", [ GeneralType('不限', 'chengmai_area_any'), GeneralType('澄迈县', '澄迈县')]),
  CityAreaInfo("临高县", [ GeneralType('不限', 'lingao_area_any'), GeneralType('临高县', '临高县')]),
  CityAreaInfo("白沙黎族自治县", [ GeneralType('不限', 'baisha_hn_area_any'), GeneralType('白沙黎族自治县', '白沙黎族自治县')]),
  CityAreaInfo("昌江黎族自治县", [ GeneralType('不限', 'changjiang_hn_area_any'), GeneralType('昌江黎族自治县', '昌江黎族自治县')]),
  CityAreaInfo("乐东黎族自治县", [ GeneralType('不限', 'ledong_hn_area_any'), GeneralType('乐东黎族自治县', '乐东黎族自治县')]),
  CityAreaInfo("陵水黎族自治县", [ GeneralType('不限', 'lingshui_hn_area_any'), GeneralType('陵水黎族自治县', '陵水黎族自治县')]),
  CityAreaInfo("保亭黎族苗族自治县", [ GeneralType('不限', 'baoting_hn_area_any'), GeneralType('保亭黎族苗族自治县', '保亭黎族苗族自治县')]),
  CityAreaInfo("琼中黎族苗族自治县", [ GeneralType('不限', 'qiongzhong_hn_area_any'), GeneralType('琼中黎族苗族自治县', '琼中黎族苗族自治县')]),
  CityAreaInfo("重庆市", [
    GeneralType('不限', 'chongqing_area_any'),
    GeneralType('万州区', '万州区'), GeneralType('涪陵区', '涪陵区'), GeneralType('渝中区', '渝中区'), GeneralType('大渡口区', '大渡口区'), GeneralType('江北区', '江北区'), GeneralType('沙坪坝区', '沙坪坝区'), GeneralType('九龙坡区', '九龙坡区'), GeneralType('南岸区', '南岸区'), GeneralType('北碚区', '北碚区'), GeneralType('万盛区', '万盛区'), GeneralType('双桥区', '双桥区'), GeneralType('渝北区', '渝北区'), GeneralType('巴南区', '巴南区'), GeneralType('黔江区', '黔江区'), GeneralType('长寿区', '长寿区'), GeneralType('江津区', '江津区'), GeneralType('合川区', '合川区'), GeneralType('永川区', '永川区'), GeneralType('南川区', '南川区'), GeneralType('綦江县', '綦江县'), GeneralType('潼南县', '潼南县'), GeneralType('铜梁县', '铜梁县'), GeneralType('大足县', '大足县'), GeneralType('荣昌县', '荣昌县'), GeneralType('璧山县', '璧山县'), GeneralType('梁平县', '梁平县'), GeneralType('城口县', '城口县'), GeneralType('丰都县', '丰都县'), GeneralType('垫江县', '垫江县'), GeneralType('武隆县', '武隆县'), GeneralType('忠县', '忠县'), GeneralType('开县', '开县'), GeneralType('云阳县', '云阳县'), GeneralType('奉节县', '奉节县'), GeneralType('巫山县', '巫山县'), GeneralType('巫溪县', '巫溪县'), GeneralType('石柱土家族自治县', '石柱土家族自治县'), GeneralType('秀山土家族苗族自治县', '秀山土家族苗族自治县'), GeneralType('酉阳土家族苗族自治县', '酉阳土家族苗族自治县'), GeneralType('彭水苗族土家族自治县', '彭水苗族土家族自治县'),
  ]),
  CityAreaInfo("成都市", [
    GeneralType('不限', 'chengdu_area_any'),
    GeneralType('锦江区', '锦江区'), GeneralType('青羊区', '青羊区'), GeneralType('金牛区', '金牛区'), GeneralType('武侯区', '武侯区'), GeneralType('成华区', '成华区'), GeneralType('龙泉驿区', '龙泉驿区'), GeneralType('青白江区', '青白江区'), GeneralType('新都区', '新都区'), GeneralType('温江区', '温江区'), GeneralType('金堂县', '金堂县'), GeneralType('双流县', '双流县'), GeneralType('郫县', '郫县'), GeneralType('大邑县', '大邑县'), GeneralType('蒲江县', '蒲江县'), GeneralType('新津县', '新津县'), GeneralType('都江堰市', '都江堰市'), GeneralType('彭州市', '彭州市'), GeneralType('邛崃市', '邛崃市'), GeneralType('崇州市', '崇州市'),
  ]),
  CityAreaInfo("自贡市", [
    GeneralType('不限', 'zigong_area_any'),
    GeneralType('自流井区', '自流井区'), GeneralType('贡井区', '贡井区'), GeneralType('大安区', '大安区'), GeneralType('沿滩区', '沿滩区'), GeneralType('荣县', '荣县'), GeneralType('富顺县', '富顺县'),
  ]),
  CityAreaInfo("攀枝花市", [
    GeneralType('不限', 'panzhihua_area_any'),
    GeneralType('东区', '东区'), GeneralType('西区', '西区'), GeneralType('仁和区', '仁和区'), GeneralType('米易县', '米易县'), GeneralType('盐边县', '盐边县'),
  ]),
  CityAreaInfo("泸州市", [
    GeneralType('不限', 'luzhou_area_any'),
    GeneralType('江阳区', '江阳区'), GeneralType('纳溪区', '纳溪区'), GeneralType('龙马潭区', '龙马潭区'), GeneralType('泸县', '泸县'), GeneralType('合江县', '合江县'), GeneralType('叙永县', '叙永县'), GeneralType('古蔺县', '古蔺县'),
  ]),
  CityAreaInfo("德阳市", [
    GeneralType('不限', 'deyang_area_any'),
    GeneralType('旌阳区', '旌阳区'), GeneralType('中江县', '中江县'), GeneralType('罗江县', '罗江县'), GeneralType('广汉市', '广汉市'), GeneralType('什邡市', '什邡市'), GeneralType('绵竹市', '绵竹市'),
  ]),
  CityAreaInfo("绵阳市", [
    GeneralType('不限', 'mianyang_area_any'),
    GeneralType('涪城区', '涪城区'), GeneralType('游仙区', '游仙区'), GeneralType('三台县', '三台县'), GeneralType('盐亭县', '盐亭县'), GeneralType('安县', '安县'), GeneralType('梓潼县', '梓潼县'), GeneralType('北川羌族自治县', '北川羌族自治县'), GeneralType('平武县', '平武县'), GeneralType('江油市', '江油市'),
  ]),
  CityAreaInfo("广元市", [
    GeneralType('不限', 'guangyuan_area_any'),
    GeneralType('利州区', '利州区'), GeneralType('元坝区', '元坝区'), GeneralType('朝天区', '朝天区'), GeneralType('旺苍县', '旺苍县'), GeneralType('青川县', '青川县'), GeneralType('剑阁县', '剑阁县'), GeneralType('苍溪县', '苍溪县'),
  ]),
  CityAreaInfo("遂宁市", [
    GeneralType('不限', 'suining_area_any'),
    GeneralType('船山区', '船山区'), GeneralType('安居区', '安居区'), GeneralType('蓬溪县', '蓬溪县'), GeneralType('射洪县', '射洪县'), GeneralType('大英县', '大英县'),
  ]),
  CityAreaInfo("内江市", [
    GeneralType('不限', 'neijiang_area_any'),
    GeneralType('市中区', '市中区'), GeneralType('东兴区', '东兴区'), GeneralType('威远县', '威远县'), GeneralType('资中县', '资中县'), GeneralType('隆昌县', '隆昌县'),
  ]),
  CityAreaInfo("乐山市", [
    GeneralType('不限', 'leshan_area_any'),
    GeneralType('市中区', '市中区'), GeneralType('沙湾区', '沙湾区'), GeneralType('五通桥区', '五通桥区'), GeneralType('金口河区', '金口河区'), GeneralType('犍为县', '犍为县'), GeneralType('井研县', '井研县'), GeneralType('夹江县', '夹江县'), GeneralType('沐川县', '沐川县'), GeneralType('峨边彝族自治县', '峨边彝族自治县'), GeneralType('马边彝族自治县', '马边彝族自治县'), GeneralType('峨眉山市', '峨眉山市'),
  ]),
  CityAreaInfo("南充市", [
    GeneralType('不限', 'nanchong_area_any'),
    GeneralType('顺庆区', '顺庆区'), GeneralType('高坪区', '高坪区'), GeneralType('嘉陵区', '嘉陵区'), GeneralType('南部县', '南部县'), GeneralType('营山县', '营山县'), GeneralType('蓬安县', '蓬安县'), GeneralType('仪陇县', '仪陇县'), GeneralType('西充县', '西充县'), GeneralType('阆中市', '阆中市'),
  ]),
  CityAreaInfo("眉山市", [
    GeneralType('不限', 'meishan_area_any'),
    GeneralType('东坡区', '东坡区'), GeneralType('仁寿县', '仁寿县'), GeneralType('彭山县', '彭山县'), GeneralType('洪雅县', '洪雅县'), GeneralType('丹棱县', '丹棱县'), GeneralType('青神县', '青神县'),
  ]),
  CityAreaInfo("宜宾市", [
    GeneralType('不限', 'yibin_area_any'),
    GeneralType('翠屏区', '翠屏区'), GeneralType('宜宾县', '宜宾县'), GeneralType('南溪县', '南溪县'), GeneralType('江安县', '江安县'), GeneralType('长宁县', '长宁县'), GeneralType('高县', '高县'), GeneralType('珙县', '珙县'), GeneralType('筠连县', '筠连县'), GeneralType('兴文县', '兴文县'), GeneralType('屏山县', '屏山县'),
  ]),
  CityAreaInfo("广安市", [
    GeneralType('不限', 'guangan_area_any'),
    GeneralType('广安区', '广安区'), GeneralType('岳池县', '岳池县'), GeneralType('武胜县', '武胜县'), GeneralType('邻水县', '邻水县'), GeneralType('华蓥市', '华蓥市'),
  ]),
  CityAreaInfo("达州市", [
    GeneralType('不限', 'dazhou_area_any'),
    GeneralType('通川区', '通川区'), GeneralType('达县', '达县'), GeneralType('宣汉县', '宣汉县'), GeneralType('开江县', '开江县'), GeneralType('大竹县', '大竹县'), GeneralType('渠县', '渠县'), GeneralType('万源市', '万源市'),
  ]),
  CityAreaInfo("雅安市", [
    GeneralType('不限', 'yaan_area_any'),
    GeneralType('雨城区', '雨城区'), GeneralType('名山县', '名山县'), GeneralType('荥经县', '荥经县'), GeneralType('汉源县', '汉源县'), GeneralType('石棉县', '石棉县'), GeneralType('天全县', '天全县'), GeneralType('芦山县', '芦山县'), GeneralType('宝兴县', '宝兴县'),
  ]),
  CityAreaInfo("巴中市", [
    GeneralType('不限', 'bazhong_area_any'),
    GeneralType('巴州区', '巴州区'), GeneralType('通江县', '通江县'), GeneralType('南江县', '南江县'), GeneralType('平昌县', '平昌县'),
  ]),
  CityAreaInfo("资阳市", [
    GeneralType('不限', 'ziyang_sc_area_any'),
    GeneralType('雁江区', '雁江区'), GeneralType('安岳县', '安岳县'), GeneralType('乐至县', '乐至县'), GeneralType('简阳市', '简阳市'),
  ]),
  CityAreaInfo("阿坝藏族羌族自治州", [
    GeneralType('不限', 'aba_area_any'),
    GeneralType('汶川县', '汶川县'), GeneralType('理县', '理县'), GeneralType('茂县', '茂县'), GeneralType('松潘县', '松潘县'), GeneralType('九寨沟县', '九寨沟县'), GeneralType('金川县', '金川县'), GeneralType('小金县', '小金县'), GeneralType('黑水县', '黑水县'), GeneralType('马尔康县', '马尔康县'), GeneralType('壤塘县', '壤塘县'), GeneralType('阿坝县', '阿坝县'), GeneralType('若尔盖县', '若尔盖县'), GeneralType('红原县', '红原县'),
  ]),
  CityAreaInfo("甘孜藏族自治州", [
    GeneralType('不限', 'ganzi_sc_area_any'),
    GeneralType('康定县', '康定县'), GeneralType('泸定县', '泸定县'), GeneralType('丹巴县', '丹巴县'), GeneralType('九龙县', '九龙县'), GeneralType('雅江县', '雅江县'), GeneralType('道孚县', '道孚县'), GeneralType('炉霍县', '炉霍县'), GeneralType('甘孜县', '甘孜县'), GeneralType('新龙县', '新龙县'), GeneralType('德格县', '德格县'), GeneralType('白玉县', '白玉县'), GeneralType('石渠县', '石渠县'), GeneralType('色达县', '色达县'), GeneralType('理塘县', '理塘县'), GeneralType('巴塘县', '巴塘县'), GeneralType('乡城县', '乡城县'), GeneralType('稻城县', '稻城县'), GeneralType('得荣县', '得荣县'),
  ]),
  CityAreaInfo("凉山彝族自治州", [
    GeneralType('不限', 'liangshan_area_any'),
    GeneralType('西昌市', '西昌市'), GeneralType('木里藏族自治县', '木里藏族自治县'), GeneralType('盐源县', '盐源县'), GeneralType('德昌县', '德昌县'), GeneralType('会理县', '会理县'), GeneralType('会东县', '会东县'), GeneralType('宁南县', '宁南县'), GeneralType('普格县', '普格县'), GeneralType('布拖县', '布拖县'), GeneralType('金阳县', '金阳县'), GeneralType('昭觉县', '昭觉县'), GeneralType('喜德县', '喜德县'), GeneralType('冕宁县', '冕宁县'), GeneralType('越西县', '越西县'), GeneralType('甘洛县', '甘洛县'), GeneralType('美姑县', '美姑县'), GeneralType('雷波县', '雷波县'),
  ]),
  CityAreaInfo("贵阳市", [
    GeneralType('不限', 'guiyang_area_any'),
    GeneralType('南明区', '南明区'), GeneralType('云岩区', '云岩区'), GeneralType('花溪区', '花溪区'), GeneralType('乌当区', '乌当区'), GeneralType('白云区', '白云区'), GeneralType('小河区', '小河区'), GeneralType('开阳县', '开阳县'), GeneralType('息烽县', '息烽县'), GeneralType('修文县', '修文县'), GeneralType('清镇市', '清镇市'),
  ]),
  CityAreaInfo("六盘水市", [
    GeneralType('不限', 'liupanshui_area_any'),
    GeneralType('钟山区', '钟山区'), GeneralType('六枝特区', '六枝特区'), GeneralType('水城县', '水城县'), GeneralType('盘县', '盘县'),
  ]),
  CityAreaInfo("遵义市", [
    GeneralType('不限', 'zunyi_area_any'),
    GeneralType('红花岗区', '红花岗区'), GeneralType('汇川区', '汇川区'), GeneralType('遵义县', '遵义县'), GeneralType('桐梓县', '桐梓县'), GeneralType('绥阳县', '绥阳县'), GeneralType('正安县', '正安县'), GeneralType('道真仡佬族苗族自治县', '道真仡佬族苗族自治县'), GeneralType('务川仡佬族苗族自治县', '务川仡佬族苗族自治县'), GeneralType('凤冈县', '凤冈县'), GeneralType('湄潭县', '湄潭县'), GeneralType('余庆县', '余庆县'), GeneralType('习水县', '习水县'), GeneralType('赤水市', '赤水市'), GeneralType('仁怀市', '仁怀市'),
  ]),
  CityAreaInfo("安顺市", [
    GeneralType('不限', 'anshun_area_any'),
    GeneralType('西秀区', '西秀区'), GeneralType('平坝县', '平坝县'), GeneralType('普定县', '普定县'), GeneralType('镇宁布依族苗族自治县', '镇宁布依族苗族自治县'), GeneralType('关岭布依族苗族自治县', '关岭布依族苗族自治县'), GeneralType('紫云苗族布依族自治县', '紫云苗族布依族自治县'),
  ]),
  CityAreaInfo("铜仁地区", [
    GeneralType('不限', 'tongren_area_any'),
    GeneralType('铜仁市', '铜仁市'), GeneralType('江口县', '江口县'), GeneralType('玉屏侗族自治县', '玉屏侗族自治县'), GeneralType('石阡县', '石阡县'), GeneralType('思南县', '思南县'), GeneralType('印江土家族苗族自治县', '印江土家族苗族自治县'), GeneralType('德江县', '德江县'), GeneralType('沿河土家族自治县', '沿河土家族自治县'), GeneralType('松桃苗族自治县', '松桃苗族自治县'), GeneralType('万山特区', '万山特区'),
  ]),
  CityAreaInfo("黔西南布依族苗族自治州", [
    GeneralType('不限', 'qianxinan_area_any'),
    GeneralType('兴义市', '兴义市'), GeneralType('兴仁县', '兴仁县'), GeneralType('普安县', '普安县'), GeneralType('晴隆县', '晴隆县'), GeneralType('贞丰县', '贞丰县'), GeneralType('望谟县', '望谟县'), GeneralType('册亨县', '册亨县'), GeneralType('安龙县', '安龙县'),
  ]),
  CityAreaInfo("毕节地区", [
    GeneralType('不限', 'bijie_area_any'),
    GeneralType('毕节市', '毕节市'), GeneralType('大方县', '大方县'), GeneralType('黔西县', '黔西县'), GeneralType('金沙县', '金沙县'), GeneralType('织金县', '织金县'), GeneralType('纳雍县', '纳雍县'), GeneralType('威宁彝族回族苗族自治县', '威宁彝族回族苗族自治县'), GeneralType('赫章县', '赫章县'),
  ]),
  CityAreaInfo("黔东南苗族侗族自治州", [
    GeneralType('不限', 'qiandongnan_area_any'),
    GeneralType('凯里市', '凯里市'), GeneralType('黄平县', '黄平县'), GeneralType('施秉县', '施秉县'), GeneralType('三穗县', '三穗县'), GeneralType('镇远县', '镇远县'), GeneralType('岑巩县', '岑巩县'), GeneralType('天柱县', '天柱县'), GeneralType('锦屏县', '锦屏县'), GeneralType('剑河县', '剑河县'), GeneralType('台江县', '台江县'), GeneralType('黎平县', '黎平县'), GeneralType('榕江县', '榕江县'), GeneralType('从江县', '从江县'), GeneralType('雷山县', '雷山县'), GeneralType('麻江县', '麻江县'), GeneralType('丹寨县', '丹寨县'),
  ]),
  CityAreaInfo("黔南布依族苗族自治州", [
    GeneralType('不限', 'qiannan_area_any'),
    GeneralType('都匀市', '都匀市'), GeneralType('福泉市', '福泉市'), GeneralType('荔波县', '荔波县'), GeneralType('贵定县', '贵定县'), GeneralType('瓮安县', '瓮安县'), GeneralType('独山县', '独山县'), GeneralType('平塘县', '平塘县'), GeneralType('罗甸县', '罗甸县'), GeneralType('长顺县', '长顺县'), GeneralType('龙里县', '龙里县'), GeneralType('惠水县', '惠水县'), GeneralType('三都水族自治县', '三都水族自治县'),
  ]),
  CityAreaInfo("昆明市", [
    GeneralType('不限', 'kunming_area_any'),
    GeneralType('五华区', '五华区'), GeneralType('盘龙区', '盘龙区'), GeneralType('官渡区', '官渡区'), GeneralType('西山区', '西山区'), GeneralType('东川区', '东川区'), GeneralType('呈贡县', '呈贡县'), GeneralType('晋宁县', '晋宁县'), GeneralType('富民县', '富民县'), GeneralType('宜良县', '宜良县'), GeneralType('石林彝族自治县', '石林彝族自治县'), GeneralType('嵩明县', '嵩明县'), GeneralType('禄劝彝族苗族自治县', '禄劝彝族苗族自治县'), GeneralType('寻甸回族彝族自治县', '寻甸回族彝族自治县'), GeneralType('安宁市', '安宁市'),
  ]),
  CityAreaInfo("曲靖市", [
    GeneralType('不限', 'qujing_area_any'),
    GeneralType('麒麟区', '麒麟区'), GeneralType('马龙县', '马龙县'), GeneralType('陆良县', '陆良县'), GeneralType('师宗县', '师宗县'), GeneralType('罗平县', '罗平县'), GeneralType('富源县', '富源县'), GeneralType('会泽县', '会泽县'), GeneralType('沾益县', '沾益县'), GeneralType('宣威市', '宣威市'),
  ]),
  CityAreaInfo("玉溪市", [
    GeneralType('不限', 'yuxi_area_any'),
    GeneralType('红塔区', '红塔区'), GeneralType('江川县', '江川县'), GeneralType('澄江县', '澄江县'), GeneralType('通海县', '通海县'), GeneralType('华宁县', '华宁县'), GeneralType('易门县', '易门县'), GeneralType('峨山彝族自治县', '峨山彝族自治县'), GeneralType('新平彝族傣族自治县', '新平彝族傣族自治县'), GeneralType('元江哈尼族彝族傣族自治县', '元江哈尼族彝族傣族自治县'),
  ]),
  CityAreaInfo("保山市", [
    GeneralType('不限', 'baoshan_area_any'),
    GeneralType('隆阳区', '隆阳区'), GeneralType('施甸县', '施甸县'), GeneralType('腾冲县', '腾冲县'), GeneralType('龙陵县', '龙陵县'), GeneralType('昌宁县', '昌宁县'),
  ]),
  CityAreaInfo("昭通市", [
    GeneralType('不限', 'zhaotong_area_any'),
    GeneralType('昭阳区', '昭阳区'), GeneralType('鲁甸县', '鲁甸县'), GeneralType('巧家县', '巧家县'), GeneralType('盐津县', '盐津县'), GeneralType('大关县', '大关县'), GeneralType('永善县', '永善县'), GeneralType('绥江县', '绥江县'), GeneralType('镇雄县', '镇雄县'), GeneralType('彝良县', '彝良县'), GeneralType('威信县', '威信县'), GeneralType('水富县', '水富县'),
  ]),
  CityAreaInfo("丽江市", [
    GeneralType('不限', 'lijiang_area_any'),
    GeneralType('古城区', '古城区'), GeneralType('玉龙纳西族自治县', '玉龙纳西族自治县'), GeneralType('永胜县', '永胜县'), GeneralType('华坪县', '华坪县'), GeneralType('宁蒗彝族自治县', '宁蒗彝族自治县'),
  ]),
  CityAreaInfo("普洱市", [
    GeneralType('不限', 'puer_area_any'),
    GeneralType('思茅区', '思茅区'), GeneralType('宁洱哈尼族彝族自治县', '宁洱哈尼族彝族自治县'), GeneralType('墨江哈尼族自治县', '墨江哈尼族自治县'), GeneralType('景东彝族自治县', '景东彝族自治县'), GeneralType('景谷傣族彝族自治县', '景谷傣族彝族自治县'), GeneralType('镇沅彝族哈尼族拉祜族自治县', '镇沅彝族哈尼族拉祜族自治县'), GeneralType('江城哈尼族彝族自治县', '江城哈尼族彝族自治县'), GeneralType('孟连傣族拉祜族佤族自治县', '孟连傣族拉祜族佤族自治县'), GeneralType('澜沧拉祜族自治县', '澜沧拉祜族自治县'), GeneralType('西盟佤族自治县', '西盟佤族自治县'),
  ]),
  CityAreaInfo("临沧市", [
    GeneralType('不限', 'lincang_area_any'),
    GeneralType('临翔区', '临翔区'), GeneralType('凤庆县', '凤庆县'), GeneralType('云县', '云县'), GeneralType('永德县', '永德县'), GeneralType('镇康县', '镇康县'), GeneralType('双江拉祜族佤族布朗族傣族自治县', '双江拉祜族佤族布朗族傣族自治县'), GeneralType('耿马傣族佤族自治县', '耿马傣族佤族自治县'), GeneralType('沧源佤族自治县', '沧源佤族自治县'),
  ]),
  CityAreaInfo("楚雄彝族自治州", [
    GeneralType('不限', 'chuxiong_area_any'),
    GeneralType('楚雄市', '楚雄市'), GeneralType('双柏县', '双柏县'), GeneralType('牟定县', '牟定县'), GeneralType('南华县', '南华县'), GeneralType('姚安县', '姚安县'), GeneralType('大姚县', '大姚县'), GeneralType('永仁县', '永仁县'), GeneralType('元谋县', '元谋县'), GeneralType('武定县', '武定县'), GeneralType('禄丰县', '禄丰县'),
  ]),
  CityAreaInfo("红河哈尼族彝族自治州", [
    GeneralType('不限', 'honghe_zz_area_any'),
    GeneralType('个旧市', '个旧市'), GeneralType('开远市', '开远市'), GeneralType('蒙自市', '蒙自市'), GeneralType('屏边苗族自治县', '屏边苗族自治县'), GeneralType('建水县', '建水县'), GeneralType('石屏县', '石屏县'), GeneralType('弥勒县', '弥勒县'), GeneralType('泸西县', '泸西县'), GeneralType('元阳县', '元阳县'), GeneralType('红河县', '红河县'), GeneralType('金平苗族瑶族傣族自治县', '金平苗族瑶族傣族自治县'), GeneralType('绿春县', '绿春县'), GeneralType('河口瑶族自治县', '河口瑶族自治县'),
  ]),
  CityAreaInfo("文山壮族苗族自治州", [
    GeneralType('不限', 'wenshan_area_any'),
    GeneralType('文山县', '文山县'), GeneralType('砚山县', '砚山县'), GeneralType('西畴县', '西畴县'), GeneralType('麻栗坡县', '麻栗坡县'), GeneralType('马关县', '马关县'), GeneralType('丘北县', '丘北县'), GeneralType('广南县', '广南县'), GeneralType('富宁县', '富宁县'),
  ]),
  CityAreaInfo("西双版纳傣族自治州", [
    GeneralType('不限', 'xsbn_area_any'),
    GeneralType('景洪市', '景洪市'), GeneralType('勐海县', '勐海县'), GeneralType('勐腊县', '勐腊县'),
  ]),
  CityAreaInfo("大理白族自治州", [
    GeneralType('不限', 'dali_zz_area_any'),
    GeneralType('大理市', '大理市'), GeneralType('漾濞彝族自治县', '漾濞彝族自治县'), GeneralType('祥云县', '祥云县'), GeneralType('宾川县', '宾川县'), GeneralType('弥渡县', '弥渡县'), GeneralType('南涧彝族自治县', '南涧彝族自治县'), GeneralType('巍山彝族回族自治县', '巍山彝族回族自治县'), GeneralType('永平县', '永平县'), GeneralType('云龙县', '云龙县'), GeneralType('洱源县', '洱源县'), GeneralType('剑川县', '剑川县'), GeneralType('鹤庆县', '鹤庆县'),
  ]),
  CityAreaInfo("德宏傣族景颇族自治州", [
    GeneralType('不限', 'dehong_area_any'),
    GeneralType('瑞丽市', '瑞丽市'), GeneralType('芒市', '芒市'), GeneralType('梁河县', '梁河县'), GeneralType('盈江县', '盈江县'), GeneralType('陇川县', '陇川县'),
  ]),
  CityAreaInfo("怒江傈僳族自治州", [
    GeneralType('不限', 'nujiang_zz_area_any'),
    GeneralType('泸水县', '泸水县'), GeneralType('福贡县', '福贡县'), GeneralType('贡山独龙族怒族自治县', '贡山独龙族怒族自治县'), GeneralType('兰坪白族普米族自治县', '兰坪白族普米族自治县'),
  ]),
  CityAreaInfo("迪庆藏族自治州", [
    GeneralType('不限', 'diqing_zz_area_any'),
    GeneralType('香格里拉县', '香格里拉县'), GeneralType('德钦县', '德钦县'), GeneralType('维西傈僳族自治县', '维西傈僳族自治县'),
  ]),
  CityAreaInfo("拉萨市", [
    GeneralType('不限', 'lasa_area_any'),
    GeneralType('城关区', '城关区'), GeneralType('林周县', '林周县'), GeneralType('当雄县', '当雄县'), GeneralType('尼木县', '尼木县'), GeneralType('曲水县', '曲水县'), GeneralType('堆龙德庆县', '堆龙德庆县'), GeneralType('达孜县', '达孜县'), GeneralType('墨竹工卡县', '墨竹工卡县'),
  ]),
  CityAreaInfo("昌都地区", [
    GeneralType('不限', 'qamdo_area_any'),
    GeneralType('昌都县', '昌都县'), GeneralType('江达县', '江达县'), GeneralType('贡觉县', '贡觉县'), GeneralType('类乌齐县', '类乌齐县'), GeneralType('丁青县', '丁青县'), GeneralType('察雅县', '察雅县'), GeneralType('八宿县', '八宿县'), GeneralType('左贡县', '左贡县'), GeneralType('芒康县', '芒康县'), GeneralType('洛隆县', '洛隆县'), GeneralType('边坝县', '边坝县'),
  ]),
  CityAreaInfo("山南地区", [
    GeneralType('不限', 'shannan_area_any'),
    GeneralType('乃东县', '乃东县'), GeneralType('扎囊县', '扎囊县'), GeneralType('贡嘎县', '贡嘎县'), GeneralType('桑日县', '桑日县'), GeneralType('琼结县', '琼结县'), GeneralType('曲松县', '曲松县'), GeneralType('措美县', '措美县'), GeneralType('洛扎县', '洛扎县'), GeneralType('加查县', '加查县'), GeneralType('隆子县', '隆子县'), GeneralType('错那县', '错那县'), GeneralType('浪卡子县', '浪卡子县'),
  ]),
  CityAreaInfo("日喀则地区", [
    GeneralType('不限', 'xigaze_area_any'),
    GeneralType('日喀则市', '日喀则市'), GeneralType('南木林县', '南木林县'), GeneralType('江孜县', '江孜县'), GeneralType('定日县', '定日县'), GeneralType('萨迦县', '萨迦县'), GeneralType('拉孜县', '拉孜县'), GeneralType('昂仁县', '昂仁县'), GeneralType('谢通门县', '谢通门县'), GeneralType('白朗县', '白朗县'), GeneralType('仁布县', '仁布县'), GeneralType('康马县', '康马县'), GeneralType('定结县', '定结县'), GeneralType('仲巴县', '仲巴县'), GeneralType('亚东县', '亚东县'), GeneralType('吉隆县', '吉隆县'), GeneralType('聂拉木县', '聂拉木县'), GeneralType('萨嘎县', '萨嘎县'), GeneralType('岗巴县', '岗巴县'),
  ]),
  CityAreaInfo("那曲地区", [
    GeneralType('不限', 'nagqu_area_any'),
    GeneralType('那曲县', '那曲县'), GeneralType('嘉黎县', '嘉黎县'), GeneralType('比如县', '比如县'), GeneralType('聂荣县', '聂荣县'), GeneralType('安多县', '安多县'), GeneralType('申扎县', '申扎县'), GeneralType('索县', '索县'), GeneralType('班戈县', '班戈县'), GeneralType('巴青县', '巴青县'), GeneralType('尼玛县', '尼玛县'),
  ]),
  CityAreaInfo("阿里地区", [
    GeneralType('不限', 'ali_area_any'),
    GeneralType('普兰县', '普兰县'), GeneralType('札达县', '札达县'), GeneralType('噶尔县', '噶尔县'), GeneralType('日土县', '日土县'), GeneralType('革吉县', '革吉县'), GeneralType('改则县', '改则县'), GeneralType('措勤县', '措勤县'),
  ]),
  CityAreaInfo("林芝地区", [
    GeneralType('不限', 'nyingchi_area_any'),
    GeneralType('林芝县', '林芝县'), GeneralType('工布江达县', '工布江达县'), GeneralType('米林县', '米林县'), GeneralType('墨脱县', '墨脱县'), GeneralType('波密县', '波密县'), GeneralType('察隅县', '察隅县'), GeneralType('朗县', '朗县'),
  ]),
  CityAreaInfo("西安市", [
    GeneralType('不限', 'xian_area_any'),
    GeneralType('新城区', '新城区'), GeneralType('碑林区', '碑林区'), GeneralType('莲湖区', '莲湖区'), GeneralType('灞桥区', '灞桥区'), GeneralType('未央区', '未央区'), GeneralType('雁塔区', '雁塔区'), GeneralType('阎良区', '阎良区'), GeneralType('临潼区', '临潼区'), GeneralType('长安区', '长安区'), GeneralType('蓝田县', '蓝田县'), GeneralType('周至县', '周至县'), GeneralType('户县', '户县'), GeneralType('高陵县', '高陵县'),
  ]),
  CityAreaInfo("铜川市", [
    GeneralType('不限', 'tongchuan_area_any'),
    GeneralType('王益区', '王益区'), GeneralType('印台区', '印台区'), GeneralType('耀州区', '耀州区'), GeneralType('宜君县', '宜君县'),
  ]),
  CityAreaInfo("宝鸡市", [
    GeneralType('不限', 'baoji_area_any'),
    GeneralType('渭滨区', '渭滨区'), GeneralType('金台区', '金台区'), GeneralType('陈仓区', '陈仓区'), GeneralType('凤翔县', '凤翔县'), GeneralType('岐山县', '岐山县'), GeneralType('扶风县', '扶风县'), GeneralType('眉县', '眉县'), GeneralType('陇县', '陇县'), GeneralType('千阳县', '千阳县'), GeneralType('麟游县', '麟游县'), GeneralType('凤县', '凤县'), GeneralType('太白县', '太白县'),
  ]),
  CityAreaInfo("咸阳市", [
    GeneralType('不限', 'xianyang_area_any'),
    GeneralType('秦都区', '秦都区'), GeneralType('杨陵区', '杨陵区'), GeneralType('渭城区', '渭城区'), GeneralType('三原县', '三原县'), GeneralType('泾阳县', '泾阳县'), GeneralType('乾县', '乾县'), GeneralType('礼泉县', '礼泉县'), GeneralType('永寿县', '永寿县'), GeneralType('彬县', '彬县'), GeneralType('长武县', '长武县'), GeneralType('旬邑县', '旬邑县'), GeneralType('淳化县', '淳化县'), GeneralType('武功县', '武功县'), GeneralType('兴平市', '兴平市'),
  ]),
  CityAreaInfo("渭南市", [
    GeneralType('不限', 'weinan_area_any'),
    GeneralType('临渭区', '临渭区'), GeneralType('华县', '华县'), GeneralType('潼关县', '潼关县'), GeneralType('大荔县', '大荔县'), GeneralType('合阳县', '合阳县'), GeneralType('澄城县', '澄城县'), GeneralType('蒲城县', '蒲城县'), GeneralType('白水县', '白水县'), GeneralType('富平县', '富平县'), GeneralType('韩城市', '韩城市'), GeneralType('华阴市', '华阴市'),
  ]),
  CityAreaInfo("延安市", [
    GeneralType('不限', 'yanan_area_any'),
    GeneralType('宝塔区', '宝塔区'), GeneralType('延长县', '延长县'), GeneralType('延川县', '延川县'), GeneralType('子长县', '子长县'), GeneralType('安塞县', '安塞县'), GeneralType('志丹县', '志丹县'), GeneralType('吴起县', '吴起县'), GeneralType('甘泉县', '甘泉县'), GeneralType('富县', '富县'), GeneralType('洛川县', '洛川县'), GeneralType('宜川县', '宜川县'), GeneralType('黄龙县', '黄龙县'), GeneralType('黄陵县', '黄陵县'),
  ]),
  CityAreaInfo("汉中市", [
    GeneralType('不限', 'hanzhong_area_any'),
    GeneralType('汉台区', '汉台区'), GeneralType('南郑县', '南郑县'), GeneralType('城固县', '城固县'), GeneralType('洋县', '洋县'), GeneralType('西乡县', '西乡县'), GeneralType('勉县', '勉县'), GeneralType('宁强县', '宁强县'), GeneralType('略阳县', '略阳县'), GeneralType('镇巴县', '镇巴县'), GeneralType('留坝县', '留坝县'), GeneralType('佛坪县', '佛坪县'),
  ]),
  CityAreaInfo("榆林市", [
    GeneralType('不限', 'yulin_shaanxi_area_any'),
    GeneralType('榆阳区', '榆阳区'), GeneralType('神木县', '神木县'), GeneralType('府谷县', '府谷县'), GeneralType('横山县', '横山县'), GeneralType('靖边县', '靖边县'), GeneralType('定边县', '定边县'), GeneralType('绥德县', '绥德县'), GeneralType('米脂县', '米脂县'), GeneralType('佳县', '佳县'), GeneralType('吴堡县', '吴堡县'), GeneralType('清涧县', '清涧县'), GeneralType('子洲县', '子洲县'),
  ]),
  CityAreaInfo("安康市", [
    GeneralType('不限', 'ankang_area_any'),
    GeneralType('汉滨区', '汉滨区'), GeneralType('汉阴县', '汉阴县'), GeneralType('石泉县', '石泉县'), GeneralType('宁陕县', '宁陕县'), GeneralType('紫阳县', '紫阳县'), GeneralType('岚皋县', '岚皋县'), GeneralType('平利县', '平利县'), GeneralType('镇坪县', '镇坪县'), GeneralType('旬阳县', '旬阳县'), GeneralType('白河县', '白河县'),
  ]),
  CityAreaInfo("商洛市", [
    GeneralType('不限', 'shangluo_area_any'),
    GeneralType('商州区', '商州区'), GeneralType('洛南县', '洛南县'), GeneralType('丹凤县', '丹凤县'), GeneralType('商南县', '商南县'), GeneralType('山阳县', '山阳县'), GeneralType('镇安县', '镇安县'), GeneralType('柞水县', '柞水县'),
  ]),
  CityAreaInfo("兰州市", [
    GeneralType('不限', 'lanzhou_area_any'),
    GeneralType('城关区', '城关区'), GeneralType('七里河区', '七里河区'), GeneralType('西固区', '西固区'), GeneralType('安宁区', '安宁区'), GeneralType('红古区', '红古区'), GeneralType('永登县', '永登县'), GeneralType('皋兰县', '皋兰县'), GeneralType('榆中县', '榆中县'),
  ]),
  CityAreaInfo("嘉峪关市", [ GeneralType('不限', 'jiayuguan_area_any'), GeneralType('嘉峪关市', '嘉峪关市')]),
  CityAreaInfo("金昌市", [
    GeneralType('不限', 'jinchang_gs_area_any'),
    GeneralType('金川区', '金川区'), GeneralType('永昌县', '永昌县'),
  ]),
  CityAreaInfo("白银市", [
    GeneralType('不限', 'baiyin_area_any'),
    GeneralType('白银区', '白银区'), GeneralType('平川区', '平川区'), GeneralType('靖远县', '靖远县'), GeneralType('会宁县', '会宁县'), GeneralType('景泰县', '景泰县'),
  ]),
  CityAreaInfo("天水市", [
    GeneralType('不限', 'tianshui_area_any'),
    GeneralType('秦州区', '秦州区'), GeneralType('麦积区', '麦积区'), GeneralType('清水县', '清水县'), GeneralType('秦安县', '秦安县'), GeneralType('甘谷县', '甘谷县'), GeneralType('武山县', '武山县'), GeneralType('张家川回族自治县', '张家川回族自治县'),
  ]),
  CityAreaInfo("武威市", [
    GeneralType('不限', 'wuwei_area_any'),
    GeneralType('凉州区', '凉州区'), GeneralType('民勤县', '民勤县'), GeneralType('古浪县', '古浪县'), GeneralType('天祝藏族自治县', '天祝藏族自治县'),
  ]),
  CityAreaInfo("张掖市", [
    GeneralType('不限', 'zhangye_area_any'),
    GeneralType('甘州区', '甘州区'), GeneralType('肃南裕固族自治县', '肃南裕固族自治县'), GeneralType('民乐县', '民乐县'), GeneralType('临泽县', '临泽县'), GeneralType('高台县', '高台县'), GeneralType('山丹县', '山丹县'),
  ]),
  CityAreaInfo("平凉市", [
    GeneralType('不限', 'pingliang_area_any'),
    GeneralType('崆峒区', '崆峒区'), GeneralType('泾川县', '泾川县'), GeneralType('灵台县', '灵台县'), GeneralType('崇信县', '崇信县'), GeneralType('华亭县', '华亭县'), GeneralType('庄浪县', '庄浪县'), GeneralType('静宁县', '静宁县'),
  ]),
  CityAreaInfo("酒泉市", [
    GeneralType('不限', 'jiuquan_area_any'),
    GeneralType('肃州区', '肃州区'), GeneralType('金塔县', '金塔县'), GeneralType('瓜州县', '瓜州县'), GeneralType('肃北蒙古族自治县', '肃北蒙古族自治县'), GeneralType('阿克塞哈萨克族自治县', '阿克塞哈萨克族自治县'), GeneralType('玉门市', '玉门市'), GeneralType('敦煌市', '敦煌市'),
  ]),
  CityAreaInfo("庆阳市", [
    GeneralType('不限', 'qingyang_area_any'),
    GeneralType('西峰区', '西峰区'), GeneralType('庆城县', '庆城县'), GeneralType('环县', '环县'), GeneralType('华池县', '华池县'), GeneralType('合水县', '合水县'), GeneralType('正宁县', '正宁县'), GeneralType('宁县', '宁县'), GeneralType('镇原县', '镇原县'),
  ]),
  CityAreaInfo("定西市", [
    GeneralType('不限', 'dingxi_area_any'),
    GeneralType('安定区', '安定区'), GeneralType('通渭县', '通渭县'), GeneralType('陇西县', '陇西县'), GeneralType('渭源县', '渭源县'), GeneralType('临洮县', '临洮县'), GeneralType('漳县', '漳县'), GeneralType('岷县', '岷县'),
  ]),
  CityAreaInfo("陇南市", [
    GeneralType('不限', 'longnan_area_any'),
    GeneralType('武都区', '武都区'), GeneralType('成县', '成县'), GeneralType('文县', '文县'), GeneralType('宕昌县', '宕昌县'), GeneralType('康县', '康县'), GeneralType('西和县', '西和县'), GeneralType('礼县', '礼县'), GeneralType('徽县', '徽县'), GeneralType('两当县', '两当县'),
  ]),
  CityAreaInfo("临夏回族自治州", [
    GeneralType('不限', 'linxia_area_any'),
    GeneralType('临夏市', '临夏市'), GeneralType('临夏县', '临夏县'), GeneralType('康乐县', '康乐县'), GeneralType('永靖县', '永靖县'), GeneralType('广河县', '广河县'), GeneralType('和政县', '和政县'), GeneralType('东乡族自治县', '东乡族自治县'), GeneralType('积石山保安族东乡族撒拉族自治县', '积石山保安族东乡族撒拉族自治县'),
  ]),
  CityAreaInfo("甘南藏族自治州", [
    GeneralType('不限', 'gannan_area_any'),
    GeneralType('合作市', '合作市'), GeneralType('临潭县', '临潭县'), GeneralType('卓尼县', '卓尼县'), GeneralType('舟曲县', '舟曲县'), GeneralType('迭部县', '迭部县'), GeneralType('玛曲县', '玛曲县'), GeneralType('碌曲县', '碌曲县'), GeneralType('夏河县', '夏河县'),
  ]),
  CityAreaInfo("西宁市", [
    GeneralType('不限', 'xining_area_any'),
    GeneralType('城东区', '城东区'), GeneralType('城中区', '城中区'), GeneralType('城西区', '城西区'), GeneralType('城北区', '城北区'), GeneralType('大通回族土族自治县', '大通回族土族自治县'), GeneralType('湟中县', '湟中县'), GeneralType('湟源县', '湟源县'),
  ]),
  CityAreaInfo("海东地区", [
    GeneralType('不限', 'haidong_area_any'),
    GeneralType('平安县', '平安县'), GeneralType('民和回族土族自治县', '民和回族土族自治县'), GeneralType('乐都县', '乐都县'), GeneralType('互助土族自治县', '互助土族自治县'), GeneralType('化隆回族自治县', '化隆回族自治县'), GeneralType('循化撒拉族自治县', '循化撒拉族自治县'),
  ]),
  CityAreaInfo("海北藏族自治州", [
    GeneralType('不限', 'haibei_area_any'),
    GeneralType('门源回族自治县', '门源回族自治县'), GeneralType('祁连县', '祁连县'), GeneralType('海晏县', '海晏县'), GeneralType('刚察县', '刚察县'),
  ]),
  CityAreaInfo("黄南藏族自治州", [
    GeneralType('不限', 'huangnan_area_any'),
    GeneralType('同仁县', '同仁县'), GeneralType('尖扎县', '尖扎县'), GeneralType('泽库县', '泽库县'), GeneralType('河南蒙古族自治县', '河南蒙古族自治县'),
  ]),
  CityAreaInfo("海南藏族自治州", [
    GeneralType('不限', 'hainan_qh_area_any'),
    GeneralType('共和县', '共和县'), GeneralType('同德县', '同德县'), GeneralType('贵德县', '贵德县'), GeneralType('兴海县', '兴海县'), GeneralType('贵南县', '贵南县'),
  ]),
  CityAreaInfo("果洛藏族自治州", [
    GeneralType('不限', 'guoluo_area_any'),
    GeneralType('玛沁县', '玛沁县'), GeneralType('班玛县', '班玛县'), GeneralType('甘德县', '甘德县'), GeneralType('达日县', '达日县'), GeneralType('久治县', '久治县'), GeneralType('玛多县', '玛多县'),
  ]),
  CityAreaInfo("玉树藏族自治州", [
    GeneralType('不限', 'yushu_area_any'),
    GeneralType('玉树县', '玉树县'), GeneralType('杂多县', '杂多县'), GeneralType('称多县', '称多县'), GeneralType('治多县', '治多县'), GeneralType('囊谦县', '囊谦县'), GeneralType('曲麻莱县', '曲麻莱县'),
  ]),
  CityAreaInfo("海西蒙古族藏族自治州", [
    GeneralType('不限', 'haixi_area_any'),
    GeneralType('格尔木市', '格尔木市'), GeneralType('德令哈市', '德令哈市'), GeneralType('乌兰县', '乌兰县'), GeneralType('都兰县', '都兰县'), GeneralType('天峻县', '天峻县'),
  ]),
  CityAreaInfo("银川市", [
    GeneralType('不限', 'yinchuan_area_any'),
    GeneralType('兴庆区', '兴庆区'), GeneralType('西夏区', '西夏区'), GeneralType('金凤区', '金凤区'), GeneralType('永宁县', '永宁县'), GeneralType('贺兰县', '贺兰县'), GeneralType('灵武市', '灵武市'),
  ]),
  CityAreaInfo("石嘴山市", [
    GeneralType('不限', 'shizuishan_area_any'),
    GeneralType('大武口区', '大武口区'), GeneralType('惠农区', '惠农区'), GeneralType('平罗县', '平罗县'),
  ]),
  CityAreaInfo("吴忠市", [
    GeneralType('不限', 'wuzhong_area_any'),
    GeneralType('利通区', '利通区'), GeneralType('红寺堡区', '红寺堡区'), GeneralType('盐池县', '盐池县'), GeneralType('同心县', '同心县'), GeneralType('青铜峡市', '青铜峡市'),
  ]),
  CityAreaInfo("固原市", [
    GeneralType('不限', 'guyuan_area_any'),
    GeneralType('原州区', '原州区'), GeneralType('西吉县', '西吉县'), GeneralType('隆德县', '隆德县'), GeneralType('泾源县', '泾源县'), GeneralType('彭阳县', '彭阳县'),
  ]),
  CityAreaInfo("中卫市", [
    GeneralType('不限', 'zhongwei_area_any'),
    GeneralType('沙坡头区', '沙坡头区'), GeneralType('中宁县', '中宁县'), GeneralType('海原县', '海原县'),
  ]),
  CityAreaInfo("乌鲁木齐市", [
    GeneralType('不限', 'urumqi_area_any'),
    GeneralType('天山区', '天山区'), GeneralType('沙依巴克区', '沙依巴克区'), GeneralType('新市区', '新市区'), GeneralType('水磨沟区', '水磨沟区'), GeneralType('头屯河区', '头屯河区'), GeneralType('达坂城区', '达坂城区'), GeneralType('米东区', '米东区'), GeneralType('乌鲁木齐县', '乌鲁木齐县'),
  ]),
  CityAreaInfo("克拉玛依市", [
    GeneralType('不限', 'karamay_area_any'),
    GeneralType('独山子区', '独山子区'), GeneralType('克拉玛依区', '克拉玛依区'), GeneralType('白碱滩区', '白碱滩区'), GeneralType('乌尔禾区', '乌尔禾区'),
  ]),
  CityAreaInfo("吐鲁番地区", [
    GeneralType('不限', 'turpan_area_any'),
    GeneralType('吐鲁番市', '吐鲁番市'), GeneralType('鄯善县', '鄯善县'), GeneralType('托克逊县', '托克逊县'),
  ]),
  CityAreaInfo("哈密地区", [
    GeneralType('不限', 'hami_area_any'),
    GeneralType('哈密市', '哈密市'), GeneralType('巴里坤哈萨克自治县', '巴里坤哈萨克自治县'), GeneralType('伊吾县', '伊吾县'),
  ]),
  CityAreaInfo("昌吉回族自治州", [
    GeneralType('不限', 'changji_area_any'),
    GeneralType('昌吉市', '昌吉市'), GeneralType('阜康市', '阜康市'), GeneralType('呼图壁县', '呼图壁县'), GeneralType('玛纳斯县', '玛纳斯县'), GeneralType('奇台县', '奇台县'), GeneralType('吉木萨尔县', '吉木萨尔县'), GeneralType('木垒哈萨克自治县', '木垒哈萨克自治县'),
  ]),
  CityAreaInfo("博尔塔拉蒙古自治州", [
    GeneralType('不限', 'bortala_area_any'),
    GeneralType('博乐市', '博乐市'), GeneralType('精河县', '精河县'), GeneralType('温泉县', '温泉县'),
  ]),
  CityAreaInfo("巴音郭楞蒙古自治州", [
    GeneralType('不限', 'bayingolin_area_any'),
    GeneralType('库尔勒市', '库尔勒市'), GeneralType('轮台县', '轮台县'), GeneralType('尉犁县', '尉犁县'), GeneralType('若羌县', '若羌县'), GeneralType('且末县', '且末县'), GeneralType('焉耆回族自治县', '焉耆回族自治县'), GeneralType('和静县', '和静县'), GeneralType('和硕县', '和硕县'), GeneralType('博湖县', '博湖县'),
  ]),
  CityAreaInfo("阿克苏地区", [
    GeneralType('不限', 'aksu_area_any'),
    GeneralType('阿克苏市', '阿克苏市'), GeneralType('温宿县', '温宿县'), GeneralType('库车县', '库车县'), GeneralType('沙雅县', '沙雅县'), GeneralType('新和县', '新和县'), GeneralType('拜城县', '拜城县'), GeneralType('乌什县', '乌什县'), GeneralType('阿瓦提县', '阿瓦提县'), GeneralType('柯坪县', '柯坪县'),
  ]),
  CityAreaInfo("克孜勒苏柯尔克孜自治州", [
    GeneralType('不限', 'kizilsu_area_any'),
    GeneralType('阿图什市', '阿图什市'), GeneralType('阿克陶县', '阿克陶县'), GeneralType('阿合奇县', '阿合奇县'), GeneralType('乌恰县', '乌恰县'),
  ]),
  CityAreaInfo("喀什地区", [
    GeneralType('不限', 'kashgar_area_any'),
    GeneralType('喀什市', '喀什市'), GeneralType('疏附县', '疏附县'), GeneralType('疏勒县', '疏勒县'), GeneralType('英吉沙县', '英吉沙县'), GeneralType('泽普县', '泽普县'), GeneralType('莎车县', '莎车县'), GeneralType('叶城县', '叶城县'), GeneralType('麦盖提县', '麦盖提县'), GeneralType('岳普湖县', '岳普湖县'), GeneralType('伽师县', '伽师县'), GeneralType('巴楚县', '巴楚县'), GeneralType('塔什库尔干塔吉克自治县', '塔什库尔干塔吉克自治县'),
  ]),
  CityAreaInfo("和田地区", [
    GeneralType('不限', 'hotan_area_any'),
    GeneralType('和田市', '和田市'), GeneralType('和田县', '和田县'), GeneralType('墨玉县', '墨玉县'), GeneralType('皮山县', '皮山县'), GeneralType('洛浦县', '洛浦县'), GeneralType('策勒县', '策勒县'), GeneralType('于田县', '于田县'), GeneralType('民丰县', '民丰县'),
  ]),
  CityAreaInfo("伊犁哈萨克自治州", [
    GeneralType('不限', 'ili_area_any'),
    GeneralType('伊宁市', '伊宁市'), GeneralType('奎屯市', '奎屯市'), GeneralType('伊宁县', '伊宁县'), GeneralType('察布查尔锡伯自治县', '察布查尔锡伯自治县'), GeneralType('霍城县', '霍城县'), GeneralType('巩留县', '巩留县'), GeneralType('新源县', '新源县'), GeneralType('昭苏县', '昭苏县'), GeneralType('特克斯县', '特克斯县'), GeneralType('尼勒克县', '尼勒克县'),
  ]),
  CityAreaInfo("塔城地区", [
    GeneralType('不限', 'tacheng_area_any'),
    GeneralType('塔城市', '塔城市'), GeneralType('乌苏市', '乌苏市'), GeneralType('额敏县', '额敏县'), GeneralType('沙湾县', '沙湾县'), GeneralType('托里县', '托里县'), GeneralType('裕民县', '裕民县'), GeneralType('和布克赛尔蒙古自治县', '和布克赛尔蒙古自治县'),
  ]),
  CityAreaInfo("阿勒泰地区", [
    GeneralType('不限', 'altay_area_any'),
    GeneralType('阿勒泰市', '阿勒泰市'), GeneralType('布尔津县', '布尔津县'), GeneralType('富蕴县', '富蕴县'), GeneralType('福海县', '福海县'), GeneralType('哈巴河县', '哈巴河县'), GeneralType('青河县', '青河县'), GeneralType('吉木乃县', '吉木乃县'),
  ]),
  CityAreaInfo("石河子市", [ GeneralType('不限', 'shihezi_area_any'), GeneralType('石河子市', '石河子市')]),
  CityAreaInfo("阿拉尔市", [ GeneralType('不限', 'aral_area_any'), GeneralType('阿拉尔市', '阿拉尔市')]),
  CityAreaInfo("图木舒克市", [ GeneralType('不限', 'tumxuk_area_any'), GeneralType('图木舒克市', '图木舒克市')]),
  CityAreaInfo("五家渠市", [ GeneralType('不限', 'wujiaqu_area_any'), GeneralType('五家渠市', '五家渠市')]),
];

List<GeneralType> priceList = [
  GeneralType('不限', 'price_any'),
  GeneralType('1000及以下', '0-1000'),
  GeneralType('1000-2000', '1000-2000'),
  GeneralType('2000-3000', '2000-3000'),
  GeneralType('3000-4000', '3000-4000'),
  GeneralType('4000-5000', '4000-5000'),
  GeneralType('5000以上', '5000-'),
];
List<GeneralType> rentTypeList = [
  GeneralType('不限', 'rent_type_any'),
  GeneralType('整租', 'whole'),
  GeneralType('合租', 'share'),
];
List<GeneralType> roomTypeList = [
  GeneralType('房屋类型1', '11'),
  GeneralType('房屋类型2', '22'),
];
List<GeneralType> orientedList = [
  GeneralType('方向1', '99'),
  GeneralType('方向2', 'cc'),
];
List<GeneralType> floorList = [
  GeneralType('楼层1', 'aa'),
  GeneralType('楼层2', 'bb'),
];

// 标签列表
List<GeneralType> tagList = [
  GeneralType('不限', 'tag_any'), // 添加 "不限" 选项
  GeneralType('近地铁', 'tag_subway'),
  GeneralType('精装修', 'tag_renovated'),
  GeneralType('拎包入住', 'tag_furnished'),
  GeneralType('押一付一', 'tag_deposit_1_pay_1'),
  GeneralType('随时看房', 'tag_anytime'),
  GeneralType('集中供暖', 'tag_central_heating'),
  GeneralType('独立卫生间', 'tag_private_bathroom'),
  GeneralType('可做饭', 'tag_cook'),
  GeneralType('有阳台', 'tag_balcony'),
  GeneralType('宠物友好', 'tag_pet_friendly'),
];
