# Create initial triggers
triggers_data = [
  { name: 'Work Stress', category: 'work', color_code: '#fd79a8' },
  { name: 'Relationship Issues', category: 'personal', color_code: '#fdcb6e' },
  { name: 'Health Concerns', category: 'health', color_code: '#00b894' },
  { name: 'Financial Worry', category: 'financial', color_code: '#fd79a8' },
  { name: 'Sleep Problems', category: 'health', color_code: '#6c757d' },
  { name: 'Social Anxiety', category: 'social', color_code: '#fdcb6e' },
  { name: 'Weather Changes', category: 'environmental', color_code: '#00b894' },
  { name: 'Family Conflict', category: 'personal', color_code: '#fd79a8' }
]

triggers_data.each do |trigger_attrs|
  Trigger.find_or_create_by(name: trigger_attrs[:name]) do |trigger|
    trigger.category = trigger_attrs[:category]
    trigger.color_code = trigger_attrs[:color_code]
    trigger.is_active = true
  end
end

# Create initial resources
resources_data = [
  {
    title: 'Deep Breathing Exercise',
    content: 'Practice the 4-7-8 breathing technique: Inhale for 4 counts, hold for 7, exhale for 8. Repeat 4 times. This technique helps activate your parasympathetic nervous system, promoting relaxation and reducing anxiety.',
    category: 'coping',
    resource_type: 'exercise'
  },
  {
    title: 'Grounding Technique',
    content: 'Use the 5-4-3-2-1 method: Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste. This technique helps bring your attention to the present moment and can be especially helpful during anxiety or panic.',
    category: 'coping',
    resource_type: 'exercise'
  },
  {
    title: 'Crisis Hotline',
    content: 'National Suicide Prevention Lifeline: 988 - Available 24/7 for crisis support. Trained counselors are available to provide immediate help and connect you with local resources.',
    category: 'crisis',
    resource_type: 'resource',
    external_url: 'https://suicidepreventionlifeline.org/'
  },
  {
    title: 'Understanding Depression',
    content: 'Depression is a common mental health condition that affects how you feel, think, and act. It can cause persistent feelings of sadness and loss of interest in activities. Depression is treatable with proper support and care.',
    category: 'education',
    resource_type: 'article'
  },
  {
    title: 'Progressive Muscle Relaxation',
    content: 'Start with your toes and work your way up. Tense each muscle group for 5 seconds, then relax for 10 seconds. This helps release physical tension and promotes mental relaxation.',
    category: 'coping',
    resource_type: 'exercise'
  },
  {
    title: 'Mindfulness Meditation',
    content: 'Sit comfortably and focus on your breath. When your mind wanders, gently bring attention back to breathing. Start with 5 minutes daily and gradually increase duration.',
    category: 'coping',
    resource_type: 'exercise'
  }
]

resources_data.each do |resource_attrs|
  Resource.find_or_create_by(title: resource_attrs[:title]) do |resource|
    resource.content = resource_attrs[:content]
    resource.category = resource_attrs[:category]
    resource.resource_type = resource_attrs[:resource_type]
    resource.external_url = resource_attrs[:external_url] if resource_attrs[:external_url]
    resource.is_published = true
  end
end

puts "Seeded #{Trigger.count} triggers and #{Resource.count} resources"
