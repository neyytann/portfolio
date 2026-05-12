class SkillGroup {
  final String category;
  final List<String> skills;
  const SkillGroup({required this.category, required this.skills});
}

class Project {
  final String number;
  final String name;
  final String description;
  final List<String> stack;
  final String github;
  final String live;
  final List<String> images;
  const Project({
    required this.number,
    required this.name,
    required this.description,
    required this.stack,
    required this.github,
    this.live = '',
    this.images = const [],
  });
}

class Experience {
  final String period;
  final String role;
  final String company;
  final String description;
  final List<String> stack;
  const Experience({
    required this.period,
    required this.role,
    required this.company,
    required this.description,
    required this.stack,
  });
}

const skillGroups = [
  SkillGroup(category: 'Mobile',  skills: ['Flutter']),
  SkillGroup(category: 'Backend', skills: ['Python', 'Go', 'Java', 'REST API']),
  SkillGroup(category: 'Systems', skills: ['Flutter', 'Go', 'PostgreSQL']),
  SkillGroup(category: 'Tooling', skills: ['Git', 'GitHub', 'PostgreSQL', 'Figma']),
];

const projects = [
  Project(
    number: '01',
    name: 'Orbis - Internship Management System',
    description: 'A centralized platform designed to streamline and automate the administration of internship programs. It enables organizations to efficiently manage intern records, monitor attendance, and track overall performance within a single system. By digitizing routine processes, it reduces manual workload and improves accuracy in handling intern-related data.',
    stack: ['Flutter', 'Go', 'REST API', 'PostgreSQL'],
    github: 'https://github.com/neyytann/orbis',
    images: [
      'assets/images/intern.png',
      'assets/images/intern2.png',
      'assets/images/intern3.png',
      'assets/images/intern4.png',
      'assets/images/intern5.png',
    ],
  ),
  Project(
    number: '02',
    name: 'Portfolio - Website',
    description: 'A portfolio website presenting my work as a software developer, highlighting projects, technical skills, and experience in building functional and efficient applications.',
    stack: ['Flutter'],
    github: 'https://neyytann.github.io/portfolio/',
    images: [
      'assets/images/portfolio.png',
      'assets/images/portfolio2.png',
      'assets/images/portfolio3.png',
      'assets/images/portfolio4.png',
      'assets/images/portfolio5.png',
      'assets/images/portfolio6.png',
    ],
  ),
  Project(
    number: '03',
    name: 'Couple Anniversary - Website',
    description: 'Welcome to the story of our first year together — a collection of memories, moments, and milestones that shaped our journey.',
    stack: ['Flutter'],
    github: 'https://neyytann.github.io/anniversary/',
    images: [
      'assets/images/anniversary.png',
      'assets/images/anniversary2.png',
      'assets/images/anniversary3.png',
      'assets/images/anniversary4.png',
      'assets/images/anniversary5.png',
    ],
  ),
];

const experiences = [
  Experience(
    period: 'Feb 2026 — Present',
    role: 'Backend Developer - INTERN',
    company: 'FDS ASYA PHILIPPINES INC.',
    description: 'I work as a backend developer, focusing on building and maintaining the server-side logic that powers applications. I design and develop APIs, manage databases, and handle authentication and authorization to ensure secure and efficient data flow. My role is to make sure that everything behind the scenes functions reliably and supports the needs of the frontend.',
    stack: ['Flutter', 'Golang', 'PostgreSQL'],
  ),
];
