# [ansible-mandrill][]

A role to install and configure [Postfix][] as a mail relay for [Mandrill][].

## Configuration

    mandrill_mydomain: example.com
    mandrill_myhostname: example.com
    mandrill_api_key: xxx-API-KEY-xxx
    mandrill_username: xxx-USERNAME-xxx

Please configure `mandrill_mydomain` and `my_hostname` as you like and contact
the [Mandrill][] website for the last two.

  [ansible-mandrill]: https://github.com/michaelcontento/ansible-mandrill
  [Postfix]: http://www.postfix.org/
  [Mandrill]: https://mandrillapp.com
