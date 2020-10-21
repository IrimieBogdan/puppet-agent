#!/bin/sh

unset LIBPATH
unset LDR_PRELOAD
unset LDR_PRELOAD64
unset LD_LIBRARY_PATH
unset GEM_HOME
unset GEM_PATH
unset DLN_LIBRARY_PATH
unset RUBYLIB
unset RUBYLIB_PREFIX
unset RUBYOPT
unset RUBYPATH
unset RUBYSHELL

# If $PATH does not match a regex for /opt/puppetlabs/bin
if [ `expr "${PATH}" : '.*/opt/puppetlabs/bin'` -eq 0 ]; then
  # Add /opt/puppetlabs/bin to a possibly empty $PATH
  PATH="${PATH:+${PATH}:}/opt/puppetlabs/bin"
  export PATH
fi

COMMAND=`basename "${0}"`

new_args=''
for arg in "$@"; do
    if test "$arg" = "-p" && "$COMMAND" = 'facter'; then
      COMMAND='puppet facts show'
    else
      new_args="$new_args$arg "
    fi
done

exec /opt/puppetlabs/puppet/bin/${COMMAND} ${new_args}