class TemplateModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final Map<String, String> initialFiles;

  const TemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.initialFiles,
  });

  static List<TemplateModel> get defaultTemplates => [
        const TemplateModel(
          id: 'empty_python',
          title: 'Empty Python Project',
          description: 'A clean slate with an empty main.py file ready for your code.',
          iconName: 'code',
          initialFiles: {
            'main.py': '#!/usr/bin/env python3\n\n"""\nProject: Clean Python Script\nCreated in PyStudio Cloud IDE\n"""\n\ndef main():\n    print("Hello from PyStudio Cloud Sandbox!")\n\nif __name__ == "__main__":\n    main()\n',
          },
        ),
        const TemplateModel(
          id: 'python_starter',
          title: 'Python Starter Kit',
          description: 'Includes modular structure, utils.py, data processing sample, and unit tests.',
          iconName: 'rocket_launch',
          initialFiles: {
            'main.py': '#!/usr/bin/env python3\nfrom utils import calculate_stats, format_output\n\ndef main():\n    print("=== PyStudio Data Processor ===")\n    data = [12, 45, 67, 89, 23, 56, 91, 34]\n    print(f"Input Data: {data}")\n    \n    stats = calculate_stats(data)\n    print(format_output(stats))\n\nif __name__ == "__main__":\n    main()\n',
            'utils.py': 'def calculate_stats(numbers: list[int]) -> dict:\n    """Calculates basic statistics for a list of integers."""\n    if not numbers:\n        return {"count": 0, "sum": 0, "avg": 0, "min": 0, "max": 0}\n    \n    return {\n        "count": len(numbers),\n        "sum": sum(numbers),\n        "avg": round(sum(numbers) / len(numbers), 2),\n        "min": min(numbers),\n        "max": max(numbers),\n    }\n\ndef format_output(stats: dict) -> str:\n    return (\n        f"Count: {stats[\'count\']}\\n"\n        f"Sum:   {stats[\'sum\']}\\n"\n        f"Avg:   {stats[\'avg\']}\\n"\n        f"Range: [{stats[\'min\']} - {stats[\'max\']}]"\n    )\n',
            'README.md': '# Python Starter Kit\n\nThis project demonstrates multi-file architecture with modules and clean imports.\n',
          },
        ),
        const TemplateModel(
          id: 'cli_example',
          title: 'CLI Tool & Math Solver',
          description: 'A command line tool demonstrating algorithms, recursion, and error handling.',
          iconName: 'terminal',
          initialFiles: {
            'main.py': '#!/usr/bin/env python3\nimport sys\nimport time\n\ndef fibonacci(n: int) -> int:\n    if n <= 0:\n        return 0\n    elif n == 1:\n        return 1\n    a, b = 0, 1\n    for _ in range(2, n + 1):\n        a, b = b, a + b\n    return b\n\ndef is_prime(n: int) -> bool:\n    if n <= 1:\n        return False\n    for i in range(2, int(n ** 0.5) + 1):\n        if n % i == 0:\n            return False\n    return True\n\ndef main():\n    print(">>> Initializing Mathematical Engine...")\n    time.sleep(0.1)\n    \n    target = 10\n    fib_val = fibonacci(target)\n    print(f"Fibonacci({target}) = {fib_val}")\n    \n    test_nums = [2, 3, 4, 17, 21, 29, 35, 97]\n    primes = [x for x in test_nums if is_prime(x)]\n    print(f"Primes in {test_nums} -> {primes}")\n    print("Execution complete!")\n\nif __name__ == "__main__":\n    main()\n',
          },
        ),
      ];
}
