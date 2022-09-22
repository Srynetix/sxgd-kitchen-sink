extends Control

var _logger := SxLog.get_logger("MyLogger")

func _ready():
    _logger.info_m("_ready", "TestSxLog scene is ready!")

func _write_log_message():
    _logger.info("This is a log message!")

func _write_error_message():
    _logger.error("This is an error message!")

func _open_debug_tools():
    GameDebugTools.show()
    GameDebugTools.show_specific_panel(SxDebugTools.PanelType.LOG)
