#' Probabilistic Adjusted Classify and Count
#'
#' It quantifies events based on testing scores, applying the Probabilistic Adjusted
#' Classify and Count (PACC) method. This method is also called Scaled Probability
#' Average (SPA).
#' @param test a numeric \code{vector} of scores predicted from the test set  (NOTE: It
#' requires calibrated scores. See \link[CORElearn]{calibrate} from \pkg{CORElearn}).
#' @param TprFpr a \code{data.frame} of true positive (\code{tpr}) and false positive
#' (\code{fpr}) rates estimated on training set, using the function
#' \code{getTPRandFPRbyThreshold()}.
#' @param thr threshold value according to the \code{tpr} and \code{fpr} were learned.
#' Default is \code{0.5}.
#' @return the class distribution in the test set.
#' @references Bella, A., Ferri, C., Hernández-Orallo, J., & Ramírez-Quintana, M. J. (2010).
#' Quantification via probability estimators. In IEEE International Conference on Data Mining
#' (pp. 737–742). Sidney.<doi.org/10.1109/ICDM.2010.75>
#' @usage PACC(test, TprFpr, thr=0.5)
#' @export
#' @examples
#' library(randomForest)
#' library(caret)
#' cv <- createFolds(aeAegypti$class, 3)
#' tr <- aeAegypti[cv$Fold1,]
#' validation <- aeAegypti[cv$Fold2,]
#' ts <- aeAegypti[cv$Fold3,]
#'
#' # -- Getting a sample from ts with 80 positive and 20 negative instances --
#' ts_sample <- rbind(ts[sample(which(ts$class==1),80),],
#'                    ts[sample(which(ts$class==2),20),])
#' scorer <- randomForest(class~., data=tr, ntree=500)
#' scores <- cbind(predict(scorer, validation, type = c("prob")), validation$class)
#' TprFpr <- getTPRandFPRbyThreshold(scores)
#' test.scores <- predict(scorer, ts_sample, type = c("prob"))
#'
#' \dontrun{
#' # -- PACC requires calibrated scores. calibrate function from the CORElearn --
#' # -- package performs the testing scores calibration --.
#'
#' library(CORElearn)
#' cal_tr <- calibrate(as.factor(scores[,3]), scores[,1], class1=1,
#' method="isoReg",assumeProbabilities=TRUE)
#' test.scores <- applyCalibration(test.scores[,1], cal_tr)
#' }
#'
#' PACC(test = test.scores, TprFpr = TprFpr)
PACC <- function(test, TprFpr, thr=0.5){

  x <- as.data.frame(t(as.numeric(TprFpr[which(TprFpr[,1] == thr),c(2,3)])))
  colnames(x) <- c("tpr", "fpr")
  TprFpr <- x

  dC <- PCC(test)

  result <- (dC[1] - TprFpr$fpr) / (TprFpr$tpr - TprFpr$fpr)
  if(result < 0 ) result <- 0
  if(result > 1 ) result <- 1
  result <- c(result, 1 - result)
  names(result) <- c("+", "-")

  return(result)
}