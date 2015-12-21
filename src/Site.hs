{-# LANGUAGE OverloadedStrings #-}

------------------------------------------------------------------------------
-- | This module is where all the routes and handlers are defined for your
-- site. The 'app' function is the initializer that combines everything
-- together and is exported by this module.
module Site
	( app
	) where

------------------------------------------------------------------------------
import           Control.Applicative
import           Data.ByteString (ByteString)
import           Data.Monoid
import qualified Data.Text as T
import           Snap.Core
import           Snap.Snaplet
import           Snap.Snaplet.Heist
import           Snap.Snaplet.Session.Backends.CookieSession
import           Snap.Util.FileServe
import           Heist.Interpreted
import Snap.Snaplet.PostgresqlSimple
------------------------------------------------------------------------------
import           Application

import Snap.Handlers

------------------------------------------------------------------------------
-- | The application's routes.
routes :: [(ByteString, Handler App App ())]
routes =
	[ ("", serveDirectory "static")
	]

------------------------------------------------------------------------------
-- | The application initializer.
app :: SnapletInit App App
app = makeSnaplet "app" "An snaplet example application." Nothing $ do
	h <- nestSnaplet "" heist $ heistInit "templates"
	s <- nestSnaplet "sess" sess $
		initCookieSessionManager "site_key.txt" "sess" (Just 3600)

	d <- nestSnaplet "db" db pgsInit

	addRoutes routes

	wrapSite (<|> notFound)

	-- only display a pretty error if we are not in development mode
	initPrettyProductionErrors

--	initFlashNotice h sess
--	addConfig h $ mempty & scInterpretedSplices .~ userSessionSplices sess
	return $ App h s d
