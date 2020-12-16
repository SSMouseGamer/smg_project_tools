import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smg_project_tools/2_utils/log/LogUtils.dart';

/*
      GroupList
  ----------------
 ｜     Header    |
 ｜ sectionHeader |
 ｜      row      |
 ｜      ...      |
 ｜ sectionFooter |
 ｜ sectionHeader |
 ｜      ...      |
 ｜ sectionFooter |
 ｜      ...      |
 ｜     Footer    |
  ----------------
 */
enum IndexPathType {
  //表头
  Header,
  //每组的头
  sectionHeader,
  //表的每一项
  row,
  //每组的尾
  sectionFooter,
  //表尾
  Footer
}

class IndexPath {
  IndexPath(this.section, this.row,
      {this.type = IndexPathType.row, this.index});

  int index;
  int section;
  int row;
  IndexPathType type;

  @override
  String toString() {
    return "IndexPath(section:" +
        section.toString() +
        ",row:" +
        row.toString() +
        ",type:" +
        type.toString() +
        ",index:" +
        index.toString() +
        ")";
  }
}

/*-=-=-=-=-=-=-=-=-=-=- UI回调接口 -=-=-=-=-=-=-=-=-=-=-=-=*/
//表头
typedef HeaderOrFooterCallback = Widget Function();
//组头
typedef HeaderOrFooterForSectionCallback = Widget Function(int section);
//row的UI
typedef CellForRowCallback = Widget Function(IndexPath indexPath);
//每一组包含的的数量
typedef SectionCountCallback = int Function(int section);

class TableDataSource {
  TableDataSource(
      {this.numberOfSections = 1,
      @required this.numberOfRowsInSection,
      @required this.cellForRowAtIndexPath,
      this.headerForSection,
      this.footerForSection,
      this.header,
      this.footer});

  //有多少组
  int numberOfSections;
  //每一组有多少row
  SectionCountCallback numberOfRowsInSection;
  //row的UI
  CellForRowCallback cellForRowAtIndexPath;

  //组头
  HeaderOrFooterForSectionCallback headerForSection;
  //组尾
  HeaderOrFooterForSectionCallback footerForSection;
  //表头
  HeaderOrFooterCallback header;
  //表尾
  HeaderOrFooterCallback footer;

  int get allItemCount => _allCount();
  int _allItemCount;

  /*-=-=-=-=-=-=-=-= public func -=-=-=-=-=-=-=-=-=-=-*/
  //UI统一返回方法
  Widget cellAtIndex(int index) {
    IndexPath indexPath = indexPathFromIndex(index);
    LogUtils.log(indexPath.toString());
    switch (indexPath.type) {
      case IndexPathType.sectionHeader:
        {
          if (headerForSection != null) {
            return headerForSection(indexPath.section);
          }
        }
        break;
      case IndexPathType.sectionFooter:
        {
          if (footerForSection != null) {
            return footerForSection(indexPath.section);
          }
        }
        break;
      case IndexPathType.row:
        {
          if (cellForRowAtIndexPath != null) {
            return cellForRowAtIndexPath(indexPath);
          }
        }
        break;
      case IndexPathType.Header:
        {
          if (header != null) {
            return header();
          }
        }
        break;
      case IndexPathType.Footer:
        {
          if (footer != null) {
            return footer();
          }
        }
        break;
      default:
        {}
        break;
    }
    return Text('IndexPathType is not valid');
  }

  /// listView中的index
  IndexPath indexPathFromIndex(int index) {
    IndexPath indexPath = IndexPath(0, 0, index: index);

    if (index == 0 && header != null) {
      //第一个
      indexPath.type = IndexPathType.Header;
      return indexPath;
    } else if (_allItemCount == index + 1 && footer != null) {
      //最后一个
      indexPath.type = IndexPathType.Footer;
      return indexPath;
    } else if (header != null) {
      index -= 1;
    }

    int amount = 0; //当前、之前section的总数
    int lastAmount = 0; //之前section的总数
    int section = -1; //index的section
    int row = 0; //index的row
    int rowsOfLastSection = 0; //最后计算的section的rows

    while (amount <= index || section == -1) {
      section += 1; //从0开始
      lastAmount += rowsOfLastSection;
      rowsOfLastSection = countBySection(section); //计算当前section的rows数量
      amount += rowsOfLastSection;
    }

    indexPath.section = section;
    indexPath.row = index - lastAmount;
    row = indexPath.row;

    if (amount == index + 1) {
      //恰好在当前section的尾部
      //若有header row需减一
      //若有footer row需减一
      indexPath.type = IndexPathType.row;
      if (headerForSection != null) {
        if (row == 0) {
          //只有header
          indexPath.type = IndexPathType.sectionHeader;
        } else {
          row -= 1;
        }
      }
      if (footerForSection != null) {
        row -= 1;
        indexPath.type = IndexPathType.sectionFooter;
      }
      indexPath.row = row;
    } else {
      //若有header row需减一
      indexPath.type = IndexPathType.row;
      if (headerForSection != null) {
        if (row == 0) {
          indexPath.type = IndexPathType.sectionHeader;
        } else {
          row -= 1;
        }
        indexPath.row = row;
      }
    }
    return indexPath;
  }

  //总item数量，这里计算的是Flutter ListView的item数量，包含了sectionHeader、sectionFooter、header和footer
  int _allCount() {
    int count = 0;

    if (header != null) {
      count += 1;
    }

    if (numberOfSections > 0) {
      count += amountBySection(numberOfSections - 1);
    }

    if (footer != null) {
      count += 1;
    }
    LogUtils.log("_allCount:" + count.toString());
    if (count == null) count = 0;
    _allItemCount = count;
    return count;
  }

  //递归计算1...section的item数量总和（每组item的数量总和）
  int amountBySection(int section) {
    int amount = countBySection(section);
    if (section > 0) {
      return amount += amountBySection(section - 1);
    }
    return amount;
  }

  //某一组的row数量 包括了sectionHeader、sectionFooter
  int countBySection(int section) {
    int amount = numberOfRowsInSection(section);

    if (headerForSection != null) {
      amount += 1;
    }

    if (footerForSection != null) {
      amount += 1;
    }
    return amount;
  }

  // ignore: non_constant_identifier_names
  void Dispose() {
    this.footerForSection = null;
    this.headerForSection = null;
    this.numberOfRowsInSection = null;
    this.numberOfSections = null;
    this.cellForRowAtIndexPath = null;
  }
}
