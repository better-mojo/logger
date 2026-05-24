from spdlog import get_logger


def main() raises -> None:
    var logger = get_logger()

    logger.info("Hello, World!")
    logger.debug("Processing item {} of {}", "5", "100")
    logger.warn("Disk usage is at {}%", "85")
