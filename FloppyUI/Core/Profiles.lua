-- FloppyUI Profiles
-- Stores the ElvUI export strings that the installer applies.
--
-- Each ElvUI export string is self-describing: when decoded, ElvUI knows
-- whether it is a profile, private, global or filters import. The installer
-- (Step 2 / Step 3) decodes and applies these via ElvUI's own import API.
--
-- HOW TO UPDATE A STRING:
--   1. In-game: /ec  ->  Profiles  ->  Export
--   2. Export Type: "Text"
--   3. Copy the string and replace the matching value below.
--   4. Save the file and reload (/floppy reload).
--
-- NOTE: Healing is intentionally left empty for now and will be added later.

local _, FloppyPrivate = ...

FloppyPrivate.Profiles = {}

----------------------------------------------------------------------
-- ElvUI layout profiles
----------------------------------------------------------------------
-- DpsTank bundles the three layout-related exports:
--   profile = E.db    (unitframes, actionbars, nameplates, layout, ...)
--   private = E.private (skins, module toggles, chat setup, ...)
--   global  = E.global  (account-wide shared data, custom styles, ...)

FloppyPrivate.Profiles.ElvUI = {

	DpsTank = {

		profile = '!E1!DZtAZjoYs(Rz(M9Bfcby7D)cGXTjgo8Iup(1ZlA8uafGEwiXkvYhtmX8BFZmRssLoqGPBhXgBmtBdLQJ8(Qs55nM7m3EftWwWcJWpl2gYzc8tB5UB2kMpX0AUn3NTWJpFXC7xDxj2oFIvhZ5cy832ZdD5(l55wrlyF4VjUliChSx29)6Szdgp3oABWR9Ixa7u08EPBvdtddCV2g4heIBt6HbdY(ty)f8cddpyd3NhY8iqoqW3ra)MWGxfBV1nKVu4g4p3((PZg(7tN40DeC67zlD93mFYvWND)t(8jTOZDDGVWM(EdatzRFgrtwSiygFpZnCU9x(6Wr3o3ENRV7o2E8Cc5rCXVheStdUaes4Ud3Lw4U6fSKHWWDP7UPbCUlzE4u(hnYpJPXcpxF(CB777E70hN(vNrdNmyUT7YaFcZw5UET7YypX743EB661aemFsZ52VN8zczwgYwlqSuFwxwAA7yUePlfEmRD6Iq2YNv7A6sAvyj7dICLu9EtDCMoE2WVCVJKzjj3MM0MTiqic29aZN7Hu6Gf)BKB9c)Uq2o(9krilqMaOqBC93XJIyBizpqqy3i(l8eUoZJ(gsaNBp4T9aBj6v27At8ip6qKDuqDQ)qyQeBn3jDqwL(gNkpHepMhs7UNZwrOOTIacuSq3xycE34qgXKrUnrIPvBj1W0ug2e76TQhZ)zCsldI9fhb)uGH5jI21q2spTSTmDOdSDkvlcZszY0xoWXNPifLOWa7X)tmpsGwtYT0YlkDQUcpEE9sTTtbu5rUfb(XrttaXhsLJ7(vNPKYECiArboD)v4(rwmeV7vgfeSnFDpyoLpd(hO8GkjSvRc87hSBpluSJ7lTT6UsbZVW8I5ld8KM(cNFx7RnB24QgMTT600SrBJ5RVSfODTz(Dxz1PtZ2wT6yEDJMTB3bFsBa6HN04ARox1QZvx32OZ1nPN0sIT7cEHlTSpW7LVE3t3fSmoQplsag8hJpBUTZ0hgn4oNl0MWfsvyAyJlUeKv7fdQ6zlGuUPvm8bwiGvxKo4LMTmUa0E7fef1lg01tTiKB(QHmUOXvWKhfeiiTJIhrf7FttaKmXv97b(8UlC9CbZI1CgnaaQPbGe2blDzEJ5(XvG6AhenMfG3x1zU9dbVYd7Xc7dCDgi8Pr2kUoKw1PvcP(bUOocn84YK5FJV1DPh3g8bFAGOLIqZ8pkKbYujGMdlCdxi)PArhM81008IMi5(rhWNTy5wjxTNoEvR8GjWZmUczYrrivmmW7OhQXfTa3Z2)3X8yoOwjIpvHVgTWFalDSByyqOd4toSrneMlBCXLxNsyMXCx1ihWvI4NJNz10GwA3Epzvh6aG0vareSP4jseOQNBz1qhMm)OWee8sSGIV405tW)BbMA6wWGLA1Al9PXYyHUpWBfp8c16BDbs2NMZF(PDYnA3evRbnNEtg48bqvtW(OnynDTOBVAj)GDZl6yLx8pVYznY)DADHvMUZdES35hFvxslZcmGmddPP)wwEnTY0d9XV06IuOTBuKB0jAoW06AupffzgZcFgm9dS)U(l3gCIhmqtr9oNG99HhXpvREOiNdL6qVcu0tbpbtH1Z)mUanRoIVUmDSEbeaS(Y4tG0z2cmd0cjDkr7uBCjeV6fHrpsTBLZj7jiHKyyDWlWWobmDUCLwWrwZdArnQn9s(HmSOOCu5NDm7ng51nokWNkDtpRhBtfm9ubFky)IIzTtxR)ZL5Oj8A9LMQ0NyYTr9MCBMGwWunRBQQz2J7f8QI)xHC)bdiXsfosxyCggN)jTQSWyuCuuP9rwOpKSGgRchf9WpyhKMlztnJJ1vMD8jBHVjAGaOE3cYoYWMkyK(G6hnSAqXAijMnRLyQ80jNARtrpTLjHoQGFgXzVWpEKJwW5OfSfzv(unPdXdEnPTdU5wWeD94Hfd)SKcv7gT09i38dyfI8i7GLPWbZKUG3dAsvTW2wq0Xyzd(TPd7pO)9DDQNj1S91QyFE05w2oiR5XCWe(i27qEtFaJYeZ4ESCmNSKfg7qRgjm921B2ZWazEifjWt4U)dazxA1kNPQulhhXTifipQfDgANk5RI2ells1We0lU1HSyb(prlyNa0PHpWteVFStX0cv8RsGTchgKV8B5l(yjVbXJDfg)mzi8KwgIey1Nc8Hjd2S3iRW3c2MOC1QiRoBNs5lY)OO9GblC3GD1oPwEaBDpP5RoUgQFBQ(Dt1VTuzBZ9xfe(Lq27r5krGqURj1D5afZbMJ)ZpMuaulSwyHS9dXQ20tBn9JJeb76J50piTge4sZ2F4W02hKYTvw018fJKd28Hi4hsvbCbGQOOLAHTqddyfhHSJ2TpPuR)Y938lJV5xS)7)yU9Z83FniCv0CBSGFVnc8MfHf9exhBrUk3KwaJLb7FhD7kNCpAM2CpiI(GW(FsvPOIkYqiAsTanB2soNdv3kf2KFlsjnJcwY8W0ar0H24EGn4vHb7HikbnqecI9DfRr1PeEqXQFbyojXWapNGrrSAiFguITCMNy7spwer8xcUZ6JFrs6tgjHpWOQigI1zQzd8ivFyH6dQn8Hq(kxzbXXfTikiCru66PQb)2uqVDne9JAKvKjJ7b6VhXdGjFRBeNfXZoxad7yA0QtBddRRmA25QRUgXdlIQ0YYWQzJR70UtRRnVoHQa7CppoFvDBIIyGKPdUj9Jd1HK6oVXSnUlZDEvpvCtQgseyjGCJuuV63fHSOBO4K82uufRvVkUyA1uv8Le5dzGelAjYvcXsfobdGGM03YkmFwr6VemPWO8uaiffEZcI4GwApw5BvxMY3ao)0hNaGnakO8rBYCfzIZH)Menjhx3tYUersiyl3Ip1jacKqoE2LfyiVDONwRSzL72gQq77FdhM763Vh47dM4mywbJbJNozA)7NnD8GIffErsPFBqENiOCIsjppmsUsRbe)x(WZVHTyri)LB2bQtX7(UgyJH7(HH7tQ63emtfmQmqlhodOnlc0alB)()RFrhsBvpGkLy(WGPO8DzOlXhjyy0kGprowsbCXjxvigapi26(Ny6wEPU1Hrd1upkbYIkURpksKN(6dGPdyDd9bBEmr5BummWJpuDrlPKUgAOJ2fzPIrtxtRrMzAsbpNGmshs4vjyyJwvml1vFI38jIiX77bSHzthbeyzgjjqOEek(kr3I7MajqGgzbBk6iDLBk9KLYmMWHtUpwSog5MsELDQ4gvRgDuvDsp67)Gk8NOePo6KYv0XRY(g1FAnuBgvqUscwyzAXblWqRry5yY4(X7(cUzrOzx79VSNImWDTR8MJDpKmEbogvazzr0phEweTYVNtl4tWGN82sjy9SDL8x)1Y7UZ86(9nmqRFBrRF)1Ff(5kWbeJea)Cvli(kfL53LUAK(yUreY8JG0E0j(MhXg(5Gcf1zWAiCifGulByULy6EGmyMLBPRwbver5pRXSKSztuxL6xgn9XdOPwqE2jW5Cj017h)tq4iHYUYncFW4G4ioMr9xWGT7L3k1bP4OPLKMdqHXbjoR1D)Nf3tU(3qKMKStTrD2(GblkD2(ptoZdhjkMQwUirtkrWXd4uKZzKILdPTrqJJoLTmpklTztJkUFEN7h2)x1ohx)iiQ6H(RdsBdLmrSpHZtrEOKqXqishaBRbAGK2QcdiqVnQiUEQ7LzQyxiUNwV7i09YKxLidjllwrwDu070WvSYR6Hj8QMsUKyQoKuTtltwmfFmRqxww32ZuD(hu190ZCGaYdeg()hdk)P47uknDZsSXx8f3eb6ZcQtv((F)hx(3)X55B9msUWkdV6s1T4mWR)LQIh6yrUCNpcyRmF9HGBLv3YryMQlyKujgLHJzd(TbZShCBD(kMXJsJHhrX4qUCqWZRrEkqk9RqN8fbruiyD9xL2hDuzVKFdDHqF1MMfi6n42HFDSUpF0nvQ)Jmxr3nR7yYsx(enoGNav)TPisOHnQnu)HIVTXzMy)hjYRMMNH67PiQiXGFkAUNLM55a4zr924NAQfMFcezk1crwawh0P1bRLs52BnP0X6AgvfnC9j5PaWM6QVnnYhTVqRhehwkkqTRhJMPw5nYMKgkgLgRxU6COunluOJcPYwU4gaOg47r1(JkSJO28DZLErwUTwjA0KoS943fBDxsrzOYEqApu2zcKXWfNvk9jvDPJbgcycfjFWpICrHM5OfdetgXxtZm7wnXjDKS4fjPdrOs1jcXsBb4iScA9HWTxP6uo6WlnQ0Ni(m9Tja71dzxFL4U9aXVDwHlwilmcPoZi3osIyMhP(cNrOeuWNsy(qgApMZIp9iKohBBYyKKi2jwO4smdsxQAC5)aXf6X7yVDGqO(8cG6qrcDud5hUUSN4s0JutCG4FYFfnyiDsf1h4WM4dKs6AHZp0dP3wD(lu5hkZ3k7f9SCuBqhXB6jHACwz8EsNtfjx)ME6Ug5Jcondxb2i(rfRIni1HDRezsd8mAuIQ3PYYECPewsFNFAwx5vYmgE4C4ev597QJBLeB6KdOwEmZn)OQLxIH))Z2CJmSpeRorl)LUvQIrCNlc7F(PqAMaV))pR(ISqAWU6R6qA68JBEPgJi6AYNHbfTDwhtkAViHvqViHtCg39FQxzSkTnFM2niyrDl(p6qcl((bX(l5jV6opZFhqt)IVsI2Xc57Hs(HrApLsmr6ZA2q5o7UtcGl0(IKMy8pssdc9ZuLDxP)XID5hn9TSvYyKtOmwyP6ZoUcqUhTsKQnHYd3fFvsEGTAfz5ew5oC)ZE(Rj1)pJuLXOXxCs5Bjco1Wy8D90HEXTMUwwCa62wxX9Ebz95KITKVqMHznVoU0xCJCtEhFgo5HUZC(gYNX2dTRofm1wFdDolv15BdE1xkYIzESq1(p2AlizSeMMq2AIr1XXPKJq)CfFahBroNx5SNLHjSNVSQREnKTKx14l4cGElZc6bV4OkoccgXgoJ4x6VwK6BKiKTQeudUNb4P0TxcWbyuuukZeqfmKHVjK4lsqzH7DmjnItDWUS5wLISOkBiWA6gfXI9Kc8KKFk8hrVnw4dwJ5TSAufxQk2bCLqbSz5iBd4szltAroKDtVIKJ57wWdvvLagCHpxChDet9jRRlu1(EyQnKLYEERuZ6GJxgXTJaCt4WwuMGqVdIeYckc9d88aceHaRI93WX8YwMmijOR)9OLWEb0mTXWZs7DUswKfDlslofZeG3oxGdTRapAlzLafuId9hwuoe5UUruVtTb8qwf7N2AK8R8Ta)IYiwQDMQFzKoImb62jFpcclEg10zM51ZbhPG)kHWdDSIVSK)N)9FqGBYcPLiOtSDgyrVDMh6WLfAihGyCQNk(ZVaoouCFbt(gvOHRsVYxv7X3sbXMvdXsyQYT4KGs5M3Oiqv5okNBRS5kPO27sY0QwkzcBR5PdzLdaao)hKffPAsyMWHro7ZhczSKsGLMxbzUAqNtwkmTyI79yc(bQSxwtJM93uHnbbR0AJw0n)1Qg3SneqISXnXnhNOdwcA3ep20SVQLA2DANm72s0VW225k1enBPMOP6fcoI6Mx5MoX8y78KMhbsbY4Xptm8ZjbdXM)kmEFHgyLMrAhtoyYGXF7Pjp0h)s(sjkjZPzArRto9hg19Bqe0oyoAHG)kzFIlVmbLJHSiuYk7zHlq3O4LLC0Jxpub8XON4(yahsrrWDspYAXYN1lnQYWHS23zVT53o0UBVrdUTYIiswGgtB9IK6jsXfGHo6bZjYgMWmy)P)KfSLEnhY3qPzJvoq88JKlXfyrqsj45SJIi5wMGnin8kHkAFT(wDhZZZP4Wc5FLrejPfVo3AQlZhQJTvT9b9ovmNId1E0T9EIE7GXlfVl4ST7YL89YeoXN9RQO2W3SCYsfo4iqpm09TNWWQi3b4GpY5p79(V6h8kypEdN6(qC8jVh9KtWTbuCjydyHd21deIhSjqxIsAJadh0x5Hq9UtKKngcVY4pbGZgGliWnH2lgksttZCtpoJK3co9jKGl9I3yJswIknVk0kQCDTz8bA4dTRO7i9P8X3a8)MFZn7ddw76XV5M78c2V)9Vo8)9',

		private = '!E1!novYUTnqm0FOII6UauKBvioObWBTJt9n5sndTmtMnmIYooanF7LJKQJTtpKtII8XhFCzkhvUSuvJEmb2SzciZDmzj(qzvPYdomAbgNaPA8MGNN3YwYJLk13)21Zxn)ULtUD24tqMbvQg)ymHnn7HdLk9wGlARQSyJGlub6hmPq80aVjMpQbf9ewoB0NVOQdU)4Le)c8Z9FUkpJQ3UwoJe5VvlZJrh1OZFTBQNqnC2e9GuxzOYzyCiyzk2KJSb0mf83Qd(8mpI8)mdv3JsSD4IuOoxKlisfh8lPFziMyl2r0L5i8BYSZeMui37T1t8njP96Qrk8)ZLH6l1G4Ly0159rg9MPysMZEEbuJNcUOhCZdKVZTbCcIPiJP8VnAPO2civQ2sgz0VN8MW(IJxlUqBdg2jOfwaJj0ttfvVIQB(rl2IljNeU6OZErxzPNEcsMmATm3fw9)IW9Dq70Kd63e7djRzke71diIoB0F(mO(2iMwMer1RAFyc5iUR5KTUNeQkAzEqCDAEEwZfYyQ2hs4cGLowcRE(plSTUkmnb8gYxNhytpLcr6dDVkcAbr5SpisiK4m6efs5NPcpRlARvc0398VxRGDOjBSsMFDBhFddEnEnTzdPBTsk5JU8TBU74d2xFNp0ZFnN)zRp(K3aV6A84QncYjGd98prxEJn(fkKw6vNqkEl6erOTGCI3lyRDTo4Iw58qeYxE)OpjalV6QyI2j1(Vd',

		global  = '!E1!f9uWQnmmm0)Or3HUb92s7LbnLaoR9MhYnAoMPizSLB3N)StzmeiPNqp90Z(SD0AUm2YxLe2QiD7J3pJPCq4bjwIwN1qIpW9yodESI1AyMafu8hnVYUKvzzayKwXJs8i(L2Azyb)FGHlldsGR0o9I14GRFpLKvrUhM0560TBEiqgvnW(17D8q3NDfVPUEdwY4zGk4EHKKTR(GGdPAJ(GQhzmbuB1fi(gfNHlZi3l3Qh0EAZtVUT6Bjrt9qCViPPaxnZQuido6pxQw7UDEsCa97d',
	},

	-- Healing layout -- to be added later.
	-- Healing = {
	--     profile = '',
	--     private = '',
	--     global  = '',
	-- },

}

----------------------------------------------------------------------
-- ElvUI aura filters (applied in Step 3)
----------------------------------------------------------------------

FloppyPrivate.Profiles.AuraFilters = '!E1!lodJlK4kjU4SYQ0YmNssTOIb8d'
