/// Single source of truth for role-specific profile fields.
///
/// One definition per field is consumed by every surface that touches role
/// details, so they can no longer drift:
///
/// - Fill Profile form (`fill_profile_screen.dart`)
/// - Edit Profile form (`edit_profile_screen.dart`)
/// - Personal Profile display rows (`personal_profile_screen.dart`)
/// - Profile completion (`profile_completion.dart`)
///
/// Dropdown behaviour for a field is still resolved separately by
/// `profileDropdownFor(key)` in `profile_field_options.dart`, and the student /
/// college `collegeName` search field is special-cased in the form screens.
/// This config only owns the field list, labels, hints and display labels.
library;

class RoleField {
  /// Key stored under `users/{uid}.roleDetails`.
  final String key;

  /// Label shown above the input in the fill/edit forms.
  final String label;

  /// Placeholder for free-text inputs (ignored by dropdown/search fields).
  final String hint;

  /// Short label used for the read-only rows on the profile page.
  final String displayLabel;

  const RoleField({
    required this.key,
    required this.label,
    required this.hint,
    required this.displayLabel,
  });
}

const Map<String, List<RoleField>> _roleFields = {
  'student': [
    RoleField(
      key: 'state',
      label: 'State',
      hint: 'Select your state',
      displayLabel: 'State',
    ),
    RoleField(
      key: 'collegeName',
      label: 'College Name',
      hint: 'Search your college',
      displayLabel: 'College',
    ),
    RoleField(
      key: 'degreeCourse',
      label: 'Degree / Course',
      hint: 'e.g. B.Tech Computer Science',
      displayLabel: 'Degree',
    ),
    RoleField(
      key: 'year',
      label: 'Year',
      hint: 'e.g. 2nd Year',
      displayLabel: 'Year',
    ),
    RoleField(
      key: 'branch',
      label: 'Branch / Specialization',
      hint: 'e.g. Artificial Intelligence',
      displayLabel: 'Branch',
    ),
    RoleField(
      key: 'skills',
      label: 'Skills',
      hint: 'e.g. Flutter, Python, Machine Learning',
      displayLabel: 'Skills',
    ),
    RoleField(
      key: 'lookingFor',
      label: 'Looking For',
      hint: 'e.g. Internship, Co-founder, Networking',
      displayLabel: 'Looking For',
    ),
  ],
  'founder': [
    RoleField(
      key: 'startupName',
      label: 'Startup Name',
      hint: 'e.g. TechVenture India',
      displayLabel: 'Startup',
    ),
    RoleField(
      key: 'startupStage',
      label: 'Startup Stage',
      hint: 'e.g. Idea, MVP, Revenue',
      displayLabel: 'Stage',
    ),
    RoleField(
      key: 'industry',
      label: 'Industry',
      hint: 'e.g. Fintech, EdTech, HealthTech',
      displayLabel: 'Industry',
    ),
    RoleField(
      key: 'startupDescription',
      label: 'Startup Description',
      hint: 'What problem are you solving?',
      displayLabel: 'About',
    ),
    RoleField(
      key: 'startupLocation',
      label: 'Startup Location',
      hint: 'e.g. Bangalore, Karnataka',
      displayLabel: 'Location',
    ),
    RoleField(
      key: 'teamSize',
      label: 'Team Size',
      hint: 'e.g. 5',
      displayLabel: 'Team Size',
    ),
    RoleField(
      key: 'businessNeeds',
      label: 'Looking For',
      hint: 'e.g. Funding, Mentors, Co-founders',
      displayLabel: 'Looking For',
    ),
  ],
  'mentor': [
    RoleField(
      key: 'profession',
      label: 'Profession / Designation',
      hint: 'e.g. CTO, Founder',
      displayLabel: 'Designation',
    ),
    RoleField(
      key: 'company',
      label: 'Company / Organization',
      hint: 'e.g. Google, IIM Ahmedabad',
      displayLabel: 'Company',
    ),
    RoleField(
      key: 'expertise',
      label: 'Expertise',
      hint: 'e.g. Product, Tech, Finance, Marketing',
      displayLabel: 'Expertise',
    ),
    RoleField(
      key: 'yearsExperience',
      label: 'Years of Experience',
      hint: 'e.g. 10',
      displayLabel: 'Experience',
    ),
    RoleField(
      key: 'industry',
      label: 'Industry',
      hint: 'e.g. SaaS, Fintech, Edtech',
      displayLabel: 'Industry',
    ),
    RoleField(
      key: 'mentorshipArea',
      label: 'Mentorship Areas',
      hint: 'e.g. Startup, Marketing, Legal',
      displayLabel: 'Mentors In',
    ),
    RoleField(
      key: 'availability',
      label: 'Availability',
      hint: 'e.g. Free, Paid, Group Sessions',
      displayLabel: 'Availability',
    ),
  ],
  'investor': [
    RoleField(
      key: 'investorType',
      label: 'Investor Type',
      hint: 'e.g. Angel Investor, VC',
      displayLabel: 'Type',
    ),
    RoleField(
      key: 'firmName',
      label: 'Firm Name',
      hint: 'e.g. Accel Partners',
      displayLabel: 'Firm',
    ),
    RoleField(
      key: 'investmentRange',
      label: 'Investment Range',
      hint: 'e.g. ₹10L – ₹1Cr',
      displayLabel: 'Ticket Size',
    ),
    RoleField(
      key: 'preferredIndustries',
      label: 'Preferred Industries',
      hint: 'e.g. Fintech, SaaS, D2C',
      displayLabel: 'Industries',
    ),
    RoleField(
      key: 'preferredStage',
      label: 'Preferred Stage',
      hint: 'e.g. Pre-Seed, Seed, Series A',
      displayLabel: 'Stage',
    ),
    RoleField(
      key: 'portfolioCompanies',
      label: 'Portfolio Companies',
      hint: 'e.g. Zepto, Razorpay',
      displayLabel: 'Portfolio',
    ),
  ],
  'college': [
    RoleField(
      key: 'cityState',
      label: 'City / State',
      hint: 'e.g. Chennai, Tamil Nadu',
      displayLabel: 'Location',
    ),
    RoleField(
      key: 'collegeName',
      label: 'College Name',
      hint: 'Search your college',
      displayLabel: 'College',
    ),
    RoleField(
      key: 'collegeType',
      label: 'College Type',
      hint: 'e.g. Engineering, Management',
      displayLabel: 'Type',
    ),
    RoleField(
      key: 'contactPersonName',
      label: 'Contact Person',
      hint: 'e.g. Dr. Ramesh Kumar',
      displayLabel: 'Contact',
    ),
    RoleField(
      key: 'designation',
      label: 'Designation',
      hint: 'e.g. Dean, Placement Officer',
      displayLabel: 'Designation',
    ),
    RoleField(
      key: 'numberOfStudents',
      label: 'Number of Students',
      hint: 'e.g. 5000',
      displayLabel: 'Students',
    ),
    RoleField(
      key: 'interestedIn',
      label: 'Interested In',
      hint: 'e.g. Startup Programs, Incubation',
      displayLabel: 'Interested In',
    ),
  ],
  'startup_enthusiast': [
    RoleField(
      key: 'interestArea',
      label: 'Interest Areas',
      hint: 'e.g. AI, Fintech, Gaming',
      displayLabel: 'Interests',
    ),
    RoleField(
      key: 'lookingFor',
      label: 'Looking For',
      hint: 'e.g. Networking, Learning, Co-founder',
      displayLabel: 'Looking For',
    ),
  ],
};

/// Ordered role fields for [role]; empty for an unknown/empty role.
List<RoleField> roleFieldsFor(String role) =>
    _roleFields[role] ?? const <RoleField>[];

/// Section title for the role details block, e.g. "Student Details".
String roleSectionLabel(String role) => switch (role) {
  'student' => 'Student Details',
  'founder' => 'Startup Details',
  'mentor' => 'Mentor Details',
  'investor' => 'Investor Details',
  'college' => 'College Details',
  'startup_enthusiast' => 'Your Interests',
  _ => 'Profile Details',
};
