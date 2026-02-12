#!/usr/bin/env python3
"""
PetSafe Test Log Analyzer
Parses XCUITest logs and extracts meaningful information
"""

import re
import sys
import json
from datetime import datetime
from pathlib import Path
from collections import defaultdict, Counter
from typing import Dict, List, Tuple

# ANSI color codes
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    BOLD = '\033[1m'
    NC = '\033[0m'  # No Color


class TestLogAnalyzer:
    def __init__(self, log_file_path: str):
        self.log_file = Path(log_file_path)
        self.log_content = ""
        self.test_results = []
        self.camera_logs = []
        self.errors = []
        self.warnings = []
        self.screenshots = []

    def load_log(self):
        """Load log file content"""
        if not self.log_file.exists():
            print(f"{Colors.RED}Error: Log file not found: {self.log_file}{Colors.NC}")
            sys.exit(1)

        with open(self.log_file, 'r') as f:
            self.log_content = f.read()

    def parse_test_results(self):
        """Extract test case results"""
        # Pattern: Test Case '-[TestClass testMethod]' passed/failed
        pattern = r"Test Case '-\[([\w]+) (test[\w]+)\]' (passed|failed)"

        matches = re.finditer(pattern, self.log_content)
        for match in matches:
            test_class = match.group(1)
            test_method = match.group(2)
            status = match.group(3)

            self.test_results.append({
                'class': test_class,
                'method': test_method,
                'status': status,
                'full_name': f"{test_class}.{test_method}"
            })

    def parse_camera_logs(self):
        """Extract camera-related debug logs"""
        # Look for our emoji-prefixed camera logs
        camera_patterns = [
            r"(🎥|📸|✨|✅|❌|⚠️|🔄|▶️|🚀|📊|👋|🎬|🔐|⚙️|♻️|📹).*",
            r"Camera.*",
            r"AVCapture.*",
            r"Preview.*layer.*",
            r"Session.*running.*"
        ]

        for pattern in camera_patterns:
            matches = re.finditer(pattern, self.log_content, re.MULTILINE)
            for match in matches:
                log_line = match.group(0).strip()
                self.camera_logs.append(log_line)

    def parse_errors(self):
        """Extract error messages"""
        error_patterns = [
            r"error:.*",
            r"Error:.*",
            r"ERROR:.*",
            r"failed:.*",
            r"assertion failure.*",
            r"❌.*"
        ]

        for pattern in error_patterns:
            matches = re.finditer(pattern, self.log_content, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                error_line = match.group(0).strip()
                if error_line not in self.errors:
                    self.errors.append(error_line)

    def parse_warnings(self):
        """Extract warning messages"""
        warning_patterns = [
            r"warning:.*",
            r"Warning:.*",
            r"WARNING:.*",
            r"⚠️.*"
        ]

        for pattern in warning_patterns:
            matches = re.finditer(pattern, self.log_content, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                warning_line = match.group(0).strip()
                if warning_line not in self.warnings:
                    self.warnings.append(warning_line)

    def parse_screenshots(self):
        """Extract screenshot references"""
        pattern = r"Screenshot.*?:\s*(.+)"
        matches = re.finditer(pattern, self.log_content, re.MULTILINE)
        for match in matches:
            self.screenshots.append(match.group(1).strip())

    def analyze(self):
        """Run all analysis"""
        print(f"{Colors.CYAN}Analyzing test logs: {self.log_file}{Colors.NC}\n")

        self.load_log()
        self.parse_test_results()
        self.parse_camera_logs()
        self.parse_errors()
        self.parse_warnings()
        self.parse_screenshots()

    def print_summary(self):
        """Print analysis summary"""
        print(f"{Colors.BOLD}═══════════════════════════════════════════════════════════{Colors.NC}")
        print(f"{Colors.BOLD}                    TEST ANALYSIS SUMMARY{Colors.NC}")
        print(f"{Colors.BOLD}═══════════════════════════════════════════════════════════{Colors.NC}\n")

        # Test Results Summary
        total_tests = len(self.test_results)
        passed = sum(1 for t in self.test_results if t['status'] == 'passed')
        failed = sum(1 for t in self.test_results if t['status'] == 'failed')

        print(f"{Colors.BOLD}Test Results:{Colors.NC}")
        print(f"  Total Tests:  {total_tests}")
        print(f"  {Colors.GREEN}Passed:       {passed}{Colors.NC}")
        print(f"  {Colors.RED}Failed:       {failed}{Colors.NC}")

        if total_tests > 0:
            success_rate = (passed / total_tests) * 100
            color = Colors.GREEN if success_rate >= 80 else Colors.YELLOW if success_rate >= 50 else Colors.RED
            print(f"  {color}Success Rate: {success_rate:.1f}%{Colors.NC}")

        print()

        # Failed Tests
        if failed > 0:
            print(f"{Colors.RED}{Colors.BOLD}Failed Tests:{Colors.NC}")
            for test in self.test_results:
                if test['status'] == 'failed':
                    print(f"  ✗ {test['full_name']}")
            print()

        # Test Class Breakdown
        class_results = defaultdict(lambda: {'passed': 0, 'failed': 0})
        for test in self.test_results:
            class_results[test['class']][test['status']] += 1

        print(f"{Colors.BOLD}Test Class Breakdown:{Colors.NC}")
        for test_class in sorted(class_results.keys()):
            passed = class_results[test_class]['passed']
            failed = class_results[test_class]['failed']
            total = passed + failed
            print(f"  {test_class}: {passed}/{total} passed")
        print()

        # Camera Debug Logs
        if self.camera_logs:
            print(f"{Colors.BOLD}Camera Debug Logs ({len(self.camera_logs)} entries):{Colors.NC}")

            # Categorize camera logs
            setup_logs = [log for log in self.camera_logs if '🎥' in log or 'setup' in log.lower()]
            session_logs = [log for log in self.camera_logs if '▶️' in log or '🚀' in log or 'running' in log.lower()]
            preview_logs = [log for log in self.camera_logs if '📸' in log or 'preview' in log.lower()]
            error_logs = [log for log in self.camera_logs if '❌' in log]

            if setup_logs:
                print(f"\n  {Colors.CYAN}Camera Setup:{Colors.NC}")
                for log in setup_logs[:10]:  # Show first 10
                    print(f"    {log}")

            if session_logs:
                print(f"\n  {Colors.CYAN}Session Status:{Colors.NC}")
                for log in session_logs[:10]:
                    print(f"    {log}")

            if preview_logs:
                print(f"\n  {Colors.CYAN}Preview Layer:{Colors.NC}")
                for log in preview_logs[:10]:
                    print(f"    {log}")

            if error_logs:
                print(f"\n  {Colors.RED}Camera Errors:{Colors.NC}")
                for log in error_logs:
                    print(f"    {log}")

            print()

        # Errors
        if self.errors:
            print(f"{Colors.RED}{Colors.BOLD}Errors ({len(self.errors)}):{Colors.NC}")
            for error in self.errors[:20]:  # Show first 20
                print(f"  {error}")
            if len(self.errors) > 20:
                print(f"  ... and {len(self.errors) - 20} more")
            print()

        # Warnings
        if self.warnings:
            print(f"{Colors.YELLOW}{Colors.BOLD}Warnings ({len(self.warnings)}):{Colors.NC}")
            for warning in self.warnings[:10]:  # Show first 10
                print(f"  {warning}")
            if len(self.warnings) > 10:
                print(f"  ... and {len(self.warnings) - 10} more")
            print()

        # Screenshots
        if self.screenshots:
            print(f"{Colors.BOLD}Screenshots Captured ({len(self.screenshots)}):{Colors.NC}")
            for screenshot in self.screenshots[:15]:
                print(f"  📸 {screenshot}")
            if len(self.screenshots) > 15:
                print(f"  ... and {len(self.screenshots) - 15} more")
            print()

    def save_json_report(self, output_path: str):
        """Save detailed report as JSON"""
        report = {
            'timestamp': datetime.now().isoformat(),
            'log_file': str(self.log_file),
            'summary': {
                'total_tests': len(self.test_results),
                'passed': sum(1 for t in self.test_results if t['status'] == 'passed'),
                'failed': sum(1 for t in self.test_results if t['status'] == 'failed'),
            },
            'test_results': self.test_results,
            'camera_logs': self.camera_logs,
            'errors': self.errors,
            'warnings': self.warnings,
            'screenshots': self.screenshots
        }

        output_file = Path(output_path)
        output_file.parent.mkdir(parents=True, exist_ok=True)

        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)

        print(f"{Colors.GREEN}Detailed JSON report saved to: {output_file}{Colors.NC}\n")


def main():
    if len(sys.argv) < 2:
        print(f"{Colors.YELLOW}Usage: {sys.argv[0]} <log_file> [output_json]{Colors.NC}")
        print(f"\nAnalyzes XCUITest logs and extracts test results, camera debug info, and errors.")
        sys.exit(1)

    log_file = sys.argv[1]
    output_json = sys.argv[2] if len(sys.argv) > 2 else None

    analyzer = TestLogAnalyzer(log_file)
    analyzer.analyze()
    analyzer.print_summary()

    if output_json:
        analyzer.save_json_report(output_json)

    # Return exit code based on test results
    failed = sum(1 for t in analyzer.test_results if t['status'] == 'failed')
    sys.exit(1 if failed > 0 else 0)


if __name__ == '__main__':
    main()
