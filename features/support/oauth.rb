OmniAuth.config.test_mode = true

OmniAuth.config.add_mock(:twitter, {  uid: '12345',
                                      provider: 'twitter',
                                      credentials: {  token:  'fake-token',
                                                      secret: 'fake-secret' },
                                      info: { nickname: 'fake-nickname'}
                                    }
                        )