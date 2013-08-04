python '2'

# CentOS doesn't have Python 3 packages
if node['platform'] != 'centos'
  file '/should_py3'

  python '3'
end

# Ubuntu 10.04 has no PyPy packages, CentOS has 1.4 but only for i686
pypy_version = value_for_platform(
  ubuntu: {'12.04' => '1.8'},
  fedora: {'19' => '2.0', '18' => '1.9'},
)

if pypy_version
  file '/should_pypy'

  python pypy_version do
    implementation :pypy
  end
end
