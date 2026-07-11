/// Shared dropdown option sets for role-detail profile fields.
///
/// Both the onboarding "Fill Profile" screen and the "Edit Profile" screen
/// resolve their dropdowns from here, keyed by the role-detail field key, so a
/// field only has to be defined as a dropdown once and both screens stay in
/// sync. Add an entry to [_dropdowns] to turn another field into a dropdown.
library;

class ProfileDropdown {
  /// Fixed choices shown in the picker.
  final List<String> options;

  /// When true the picker adds an "Other" choice that lets the user type a
  /// custom value, keeping the field flexible.
  final bool allowOther;

  const ProfileDropdown(this.options, {this.allowOther = true});
}

// ── Student ────────────────────────────────────────────────────────────────
const _studentYear = <String>[
  '1st Year',
  '2nd Year',
  '3rd Year',
  '4th Year',
  'Graduated',
];

const _studentBranch = <String>[
  'CSE',
  'IT',
  'AIML',
  'Data Science',
  'Mechanical',
  'Civil',
  'EEE',
  'ECE',
];

// Common degrees/courses pursued in India.
const _degreeCourse = <String>[
  'B.Tech',
  'B.E.',
  'B.Sc',
  'B.Com',
  'BA',
  'BBA',
  'BCA',
  'LLB',
  'MBBS',
  'M.Tech',
  'M.Sc',
  'MA',
  'MBA',
  'MCA',
  'Ph.D',
  'Diploma',
];

// Shared by student and startup-enthusiast roles (both use the `lookingFor` key).
const _lookingFor = <String>[
  'Internship',
  'Co-founder',
  'Networking',
  'Learning',
  'Job',
];

// ── Founder ──────────────────────────────────────────────────────────────────
const _startupStage = <String>[
  'Idea',
  'MVP',
  'Early Revenue',
  'Growth/Scaling',
  'Profitable',
];

const _teamSize = <String>['Solo', '2–5', '6–10', '11–25', '26–50', '50+'];

const _businessNeeds = <String>[
  'Funding',
  'Mentors',
  'Hiring',
  'Co-founder',
  'Partnerships',
];

// ── Mentor ───────────────────────────────────────────────────────────────────
const _yearsExperience = <String>['0–2', '3–5', '6–10', '11–15', '16+'];

const _availability = <String>['Free', 'Paid', 'Group sessions'];

// ── Investor ─────────────────────────────────────────────────────────────────
const _investorType = <String>[
  'Angel',
  'VC',
  'Micro VC',
  'Family Office',
  'Syndicate',
  'Corporate',
];

const _investmentRange = <String>[
  '<₹10L',
  '₹10L–50L',
  '₹50L–1Cr',
  '₹1Cr–5Cr',
  '₹5Cr+',
];

const _preferredStage = <String>[
  'Pre-Seed',
  'Seed',
  'Series A',
  'Series B+',
  'Growth',
];

// ── College ──────────────────────────────────────────────────────────────────
const _collegeType = <String>[
  'Engineering',
  'Management',
  'University',
  'Arts & Science',
  'Medical',
  'Polytechnic',
];

const _numberOfStudents = <String>[
  '<500',
  '500–1K',
  '1K–5K',
  '5K–10K',
  '10K+',
];

const _designation = <String>[
  'Placement Officer',
  'Dean',
  'Director',
  'Professor',
  'HoD',
  'Incubation Manager',
];

// ── Shared: Indian states & union territories (for any location field) ────────
const _indianStates = <String>[
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Andaman & Nicobar Islands',
  'Chandigarh',
  'Dadra & Nagar Haveli and Daman & Diu',
  'Delhi',
  'Jammu & Kashmir',
  'Ladakh',
  'Lakshadweep',
  'Puducherry',
];

/// Field key → dropdown definition. Keys match the role-detail keys used by the
/// fill-profile and edit-profile screens.
const Map<String, ProfileDropdown> _dropdowns = {
  // Student
  'year': ProfileDropdown(_studentYear, allowOther: false),
  'branch': ProfileDropdown(_studentBranch),
  'degreeCourse': ProfileDropdown(_degreeCourse),
  // Student + startup enthusiast
  'lookingFor': ProfileDropdown(_lookingFor),
  // Founder
  'startupStage': ProfileDropdown(_startupStage, allowOther: false),
  'teamSize': ProfileDropdown(_teamSize, allowOther: false),
  'businessNeeds': ProfileDropdown(_businessNeeds),
  'startupLocation': ProfileDropdown(_indianStates),
  // Mentor
  'yearsExperience': ProfileDropdown(_yearsExperience, allowOther: false),
  'availability': ProfileDropdown(_availability, allowOther: false),
  // Investor
  'investorType': ProfileDropdown(_investorType, allowOther: false),
  'investmentRange': ProfileDropdown(_investmentRange, allowOther: false),
  'preferredStage': ProfileDropdown(_preferredStage, allowOther: false),
  // College
  'collegeType': ProfileDropdown(_collegeType, allowOther: false),
  'numberOfStudents': ProfileDropdown(_numberOfStudents, allowOther: false),
  'designation': ProfileDropdown(_designation),
  'cityState': ProfileDropdown(_indianStates),
  // Student state — drives the state-filtered college picker.
  'state': ProfileDropdown(_indianStates),
  // Shared location field (edit profile "About" section)
  'location': ProfileDropdown(_indianStates),
};

/// Returns the dropdown definition for [fieldKey], or null if the field should
/// remain a free-text input.
ProfileDropdown? profileDropdownFor(String fieldKey) => _dropdowns[fieldKey];
