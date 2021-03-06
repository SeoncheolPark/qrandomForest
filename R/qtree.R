#' Build quantile regression trees using tilted absolute value loss function
#'
#' Ordinary regression trees use the mean squared error loss function. The qtree function uses the tilted absolute value loss function (a specific case is the LAD trees) with the same speed as that of regular trees.
#'
#' @return A class outtree
#' @examples
#' set.seed(1)
#' library('tree')
#' x1 <- c(2,4,3,7,8)
#' x1 <- x1 + rnorm(5)
#' x2 <- c(12,19,17,3,5)
#' x2 <- x2 + rnorm(5)
#' y <- c(-3, 2, 0, 1, 12)
#' y <- y + rnorm(5)
#' data.simple <- data.frame(x1,x2,y)
#' mod.data <- qtree(y ~ ., data = data.simple, mindev = 0.01, tau = 0.5, minsize = 2, mincut = 1)
#' @useDynLib qrandomForest, .registration = TRUE
#' @importFrom stats model.extract na.pass
#' @exportPattern ^[[:alpha:]]+

qtree <- function (formula,
                   data,
                   mindev=0.01,
                   mincut=5,
                   minsize=10,
                   tau=0.5,
                   na.action = na.pass,
                   model = FALSE,
                   x = FALSE,y = TRUE,
                   wts = TRUE,...)
{

	if (is.data.frame(model)){
		m <- model
		model <- FALSE
	}
	else{
		m <- match.call(expand.dots = FALSE)
		m$mindev <- m$mincut <- m$minsize <- m$tau <- m$model <- m$x <- m$y <- m$wts <- NULL
		m[[1L]] <- as.name("model.frame.default")
		m <- eval.parent(m)
	}

	CALL = match.call()
	Terms <- attr(m,"terms")
	if (any(attr(Terms, "order") > 1)){
        	stop("qtree cannot handle interaction terms")
	}
	if(any(lapply(m,class)=="factor"))
		stop("qtree cannot handle categorical input yet!")
	# extract response variable
    Y <- model.extract(m, "response")
    if (is.matrix(Y) && ncol(Y) > 1L)
        stop("trees cannot handle multiple responses")
    w <- model.extract(m, "weights")
    if (!length(w))
        w <- rep(1, nrow(m))
    if (any(yna <- is.na(Y))) {
        Y[yna] <- 1
        w[yna] <- 0
    }
    if (2*mincut > minsize) {
        stop("minsize should be atleast 2*mincut")
    }
    offset <- attr(Terms, "offset")
    if (!is.null(offset)) {
        offset <- m[[offset]]
        Y <- Y - offset
    }

    X <- as.matrix(m[,-1])
	xlevels0 <- attr(X, "column.levels")
    if (is.null(xlevels0)) {
        xlevels0 <- rep(list(NULL), ncol(X))
        names(xlevels0) <- dimnames(X)[[2L]]
    }

	nobs <- length(Y)
    if (nobs == 0L)
        stop("no observations from which to fit a model")
        mylist <- qtreeCPP(X,Y,mindev,mincut,minsize,tau)

	ourtree = with(mylist, {
        splits = NULL
        splits = rbind(splits, replicate(2, replicate(length(val),
            "")))
        colnames(splits) = c("cutleft", "cutright")
        indadd = which(valguide == 1)
        splits[indadd, 1] = paste("<", val[indadd], sep = "")
        splits[indadd, 2] = paste(">", val[indadd], sep = "")
        splits = as.array(splits)
        yval = as.numeric(round(yval, 5))
        dev = as.numeric(round(dev, 4))
		# columns names can be different from "X1"... "Xn"
        varind = (var!="<leaf>")
        varind2 = as.integer(substr(var[varind] ,2,10000L))
        var[varind] = colnames(X)[varind2]
        var = factor(var, levels = c("<leaf>", names(xlevels0)))
        mydataframe = data.frame(var = var, n = n, dev = dev, yval = yval)
        mydataframe$splits = splits
        rownames(mydataframe) = nodeID
        varleaf = which(var == "<leaf>")
        ## mywhere = integer()
        ## for (i in c(1:length(varleaf))) {
        ##     indices = leaflist[[i]] + 1
        ##     mywhere[indices] = varleaf[i]
        ## }
        ## browser()
        ## names(mywhere) = c(1:length(Y))
        otree = list(frame = mydataframe,terms = Terms,
			call = CALL)
        ## otree = list(frame = mydataframe, where = mywhere, terms = Terms,
	## 		call = CALL)
        ## attr(otree$where, "names") <- row.names(m)
	    if (length(n) > 1L)
    	    class(otree) <- "tree"
    	else class(otree) <- c("singlenode", "tree")
    	attr(otree, "xlevels") <- xlevels0
	    if (is.logical(model) && model)
    	    otree$model <- m
	    if (x)
    	    otree$x <- X
	    if (y)
    	    otree$y <- Y
	    if (wts)
    	    otree$weights <- w
		otree
	})
	return(ourtree)
}
