import 'package:dedida/Constants.dart';
import 'package:flutter/foundation.dart';

class Settings {
  static final Settings _instance = Settings._();

  Settings._();

  factory Settings() {
    return _instance;
  }

  List<String> _usedDatasets = [];

  List<String> get usedDatasets => _usedDatasets;

  set usedDatasets(List<String> datasets) {
    _usedDatasets = datasets;
  }

  void addRemoveUsedDataset(String datasetName) {
    /// Add or remove datasetName from the list of used datasets. If it is
    /// already included, it will be removed, and vice versa. If it is not a
    /// valid dataset name (defined by kDatasetsNames in Constants.dart), do not
    /// do anything.
    if (!kDatasetsNames.contains(datasetName)) {
      if (kDebugMode) {
        print("Trying to add or remove invalid dataset $datasetName");
      }
    } else {
      if (_usedDatasets.contains(datasetName)) {
        _usedDatasets.remove(datasetName);
      } else {
        _usedDatasets.add(datasetName);
      }
    }
  }

  void addUsedDataset(String datasetName) {
    /// If datasetName is a valid dataset name (kDatasetsNames contains it), add it
    /// to the _usedDatasets list (if not yet present).
    if (!kDatasetsNames.contains(datasetName)) {
      if (kDebugMode) {
        print("Trying to add or remove invalid dataset $datasetName");
      }
    } else {
      if (!_usedDatasets.contains(datasetName)) {
        _usedDatasets.add(datasetName);
      }
    }
  }

  void removeUsedDataset(String datasetName) {
    /// If datasetName is a valid dataset name (kDatasetsNames contains it), remove it
    /// from the _usedDatasets list (if present).
    if (!kDatasetsNames.contains(datasetName)) {
      if (kDebugMode) {
        print("Trying to add or remove invalid dataset $datasetName");
      }
    } else {
      if (_usedDatasets.contains(datasetName)) {
        _usedDatasets.remove(datasetName);
      }
    }
  }

  // Named constructor fromMap
  Settings.fromMap(Map<String, dynamic> settingsMap) {
    _usedDatasets = settingsMap.containsKey("usedDatasets")
        ? List<String>.from(settingsMap["usedDatasets"])
        : [];
  }
}
