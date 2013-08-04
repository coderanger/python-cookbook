py2 = python '2'

python_virtualenv '/venv'

python_virtualenv '/venv2' do
  python '2'
end

python_virtualenv '/venv2b' do
  python py2
end
