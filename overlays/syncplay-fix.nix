# Fixes syncplay 1.7.5 crashing on connect with pyOpenSSL 26.
# X509.get_extension() was removed in pyOpenSSL 25+, so handshakeCompleted()
# threw AttributeError right after the TLS handshake and the client looped
# forever on "Connection lost in a non-clean fashion". Rewrites the
# subjectAltName read to use the cryptography API instead.
# Drop this overlay once nixpkgs ships a fix or syncplay updates.
final: prev:
let
  sanPatch = builtins.toFile "syncplay-pyopenssl26-san.patch" ''
    --- a/syncplay/protocols.py
    +++ b/syncplay/protocols.py
    @@ -401,9 +401,12 @@
                 self.sendHello()
                 return

    -        for x in range(0,self._serverCertificateTLS.get_extension_count()):
    -            if (self._serverCertificateTLS.get_extension(x).get_short_name() == b'subjectAltName'):
    -                self._subjectTLS = self._serverCertificateTLS.get_extension(x).__str__().replace("DNS:", "")
    +        try:
    +            from cryptography import x509 as _x509
    +            _san = self._serverCertificateTLS.to_cryptography().extensions.get_extension_for_class(_x509.SubjectAlternativeName)
    +            self._subjectTLS = ", ".join(_san.value.get_values_for_type(_x509.DNSName))
    +        except Exception:
    +            pass

             if not self._subjectTLS:
                 self._subjectTLS = self._client._config.get("host", "") or ""
  '';
in
{
  syncplay = prev.syncplay.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ sanPatch ];
  });
}
