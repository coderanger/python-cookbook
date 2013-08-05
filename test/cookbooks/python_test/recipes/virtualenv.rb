py2 = python '2'

python_virtualenv '/venv'

python_virtualenv '/venv2' do
  python '2'
end

python_virtualenv '/venv2b' do
  python py2
end

group 'venv2c' do
  system true
end

user 'venv2c' do
  gid 'venv2c'
  system true
  shell '/bin/false'
end

directory '/venv2c' do
  owner 'venv2c'
  group 'venv2c'
end

python_virtualenv '/venv2c/venv' do
  user 'venv2c'
  group 'venv2c'
end
